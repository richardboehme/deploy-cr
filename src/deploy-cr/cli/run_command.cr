class DeployCR::CLI::RunCommand

  def self.run
    if ARGV.size > 1 
      puts "Unknown options detected: #{ARGV[1..-1].join(", ")}\nTry ./bin/#{BINNAME} run help"
      return
    end

    stage = ARGV.shift.presence

    if !stage || stage == "help"
      print_help
      return
    end

    status = Process.run(command: "crystal", args: ["config/deployment/#{stage}.cr", "--error-trace"], output: STDOUT, error: STDOUT, chdir: Path.new(Process.executable_path.not_nil!).parent.parent.to_s)
  end

  def self.print_help
    puts(
      <<-EOS
      The run command deploys your application.
      You must specify a stage that should be used.

      Example:
        ./bin/#{BINNAME} run production
      EOS
    )
  end
  
end