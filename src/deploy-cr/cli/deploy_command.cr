require "clip"

module DeployCR::CLI
  @[Clip::Doc("DeployCR is a tool to deploy crystal applications to a server.")]
  abstract struct DeployCommand
    include Clip::Mapper

    Clip.add_commands({
      "init" => InitCommand,
      "run"  => RunCommand,
    })

    def self.run
      begin
        command = self.parse
      rescue ex : Clip::Error
        puts ex
        exit
      end

      case command
      when Clip::Mapper::Help
        puts command.help
      else
        command.run
      end
    end

    abstract def run
  end
end
