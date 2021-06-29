require "teeplate"
require "../deployment"

module DeployCR::CLI
  @[Clip::Doc("Initialize your project with deployment settings")]
  struct InitCommand < DeployCommand
    include Clip::Mapper

    @[Clip::Doc("Enable asset compilation via npm")]
    @[Clip::Option("--npm")]
    property? npm = false

    @[Clip::Doc("Cross-compile your binary for deployment")]
    @[Clip::Option("--cross-compile")]
    property? cross_compile = false

    @[Clip::Doc("Apply default settings for deploying an Amber application")]
    @[Clip::Option("--amber")]
    property? amber = false

    def run
      if !cross_compile?
        raise TODO.new("normal compile mode")
      end

      Template.new(self).render(".", list: true, color: true, interactive: true)
    end

    class Template < Teeplate::FileTree
      directory "#{__DIR__}/../templates/init"

      property command : InitCommand
      forward_missing_to(command)

      def initialize(@command); end
    end
  end
end
