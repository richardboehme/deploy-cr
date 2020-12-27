require "./init_command"
require "./run_command"

class DeployCR::CLI::DeployCommand

  def self.run
    if ARGV.empty?
      print_help
      return
    end

    case ARGV.shift
    when "init"
      DeployCR::CLI::InitCommand.run
    when "run"
      DeployCR::CLI::RunCommand.run
    when "check"
      # CheckCommand.run
    else
      print_help 
    end
  end

  def self.print_help
    puts <<-EOS
    DeployCR is a tool to deploy amber applications to production
    
    Usage:
        ./bin/#{BINNAME} <subcommand> [subcommand options]

        You can find information about subcommand options by running
          ./bin/#{BINNAME} <subcommand> help

    Commands:
        init              Initialize your project with deployment settings
        run [stage]       Deploys your application to the supplied stage
        check             Checks the remote server connection
    EOS
  end

end