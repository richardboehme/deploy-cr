require "clip"

module DeployCR::CLI
  @[Clip::Doc("DeployCR is a tool to deploy crystal applications to a server.")]
  abstract struct DeployCommand
    include Clip::Mapper

    Clip.add_commands({
      "init" => InitCommand,
      "run"  => RunCommand,
    })

    def self.run(arguments)
      begin
        command = self.parse(arguments)
      rescue ex : Clip::Error
        DeployCR.stdout.puts ex
        return
      end

      case command
      when Clip::Mapper::Help
        DeployCR.stdout.puts command.help
      else
        command.run
      end
    end

    abstract def run
  end
end
