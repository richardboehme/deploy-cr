require "clip"

module DeployCR::CLI
  @[Clip::Doc("Deploy your application to the supplied stage")]
  struct RunCommand < DeployCR::CLI::DeployCommand
    include Clip::Mapper
    include DeployCR

    @[Clip::Doc("The stage your application should be deployed to.")]
    getter stage : String

    def run
      # TODO: check if stage exists
      status =
        DeployCR::Command.new(
          "crystal",
          ["config/deployment/#{stage}.cr", "--error-trace"],
          chdir: app_path
        ).run
    end
  end
end
