require "clip"

module DeployCR::CLI
  @[Clip::Doc("Deploy your application to the supplied stage")]
  struct RunCommand < DeployCR::CLI::DeployCommand
    include Clip::Mapper

    @[Clip::Doc("The stage your application should be deployed to.")]
    getter stage : String

    def run
      # TODO: check if stage exists
      status =
        Process.run(
          command: "crystal",
          args: ["config/deployment/#{stage}.cr", "--error-trace"],
          output: STDOUT,
          error: STDOUT,
          chdir: Path.new(Process.executable_path.not_nil!).parent.parent.to_s
        )
    end
  end
end
