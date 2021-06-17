require "teeplate"
require "../deployment"

module DeployCR::CLI
  @[Clip::Doc("Initialize your project with deployment settings")]
  struct InitCommand < DeployCommand
    include Clip::Mapper

    @[Clip::Doc("Enable/Disable asset compilation via npm")]
    property? npm = true

    @[Clip::Doc("Cross-compile your binary for deployment")]
    @[Clip::Option("--cross-compile")]
    property? cross_compile = false

    def run
      if !cross_compile?
        raise TODO.new
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