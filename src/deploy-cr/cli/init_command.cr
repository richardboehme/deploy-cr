require "teeplate"
require "../deployment"

class DeployCR::CLI::InitCommand

  AVAILABLE_OPTIONS = [
    "--skip-npm",
    "--cross-compile"
  ]

  def self.run
    case ARGV.first?
    when "help"
      print_help
    else
      unknown_options = ARGV - AVAILABLE_OPTIONS
      if unknown_options.any?
        puts "Unknown options detected: #{unknown_options.join(", ")}\nTry ./bin/#{BINNAME} init help"
        return
      end

      Template.new(ARGV).render(".", list: true, color: true, interactive: true)
    end
  end

  def self.print_help
    puts(
      <<-EOS
      The init command creates default configuration files needed to deploy your application.
      You can configure the default config with the following options.

      Options:
          --skip-npm            Skip compiling npm assets
          --cross-compile       Cross-compile your binary for deployment
      EOS
    )
  end

  class Template < Teeplate::FileTree
    directory "#{__DIR__}/../templates/init"

    property options : Array(String)

    def initialize(@options); end

    def skip_npm?
      return options.includes?("--skip-npm")
    end
  end

end