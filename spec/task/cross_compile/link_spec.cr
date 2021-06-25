require "../../spec_helper"
require "../../../src/deploy-cr/deployment"
require "../../../src/deploy-cr/task/cross_compile/compile"
require "../../../src/deploy-cr/task/cross_compile/link"

private class Task < DeployCR::Deployment
  include Task::CrossCompile::Properties

  step Task::CrossCompile::Link
end

describe DeployCR::Task::CrossCompile::Link do
  it "produce correct commands" do
    operation = 
      Task.configure do |config|
        config.user = "user"
        config.host = "host"

        config.link_command = "cc #{config.app_path.join(config.tmppath)} bar/foo/libcrystal.a foo"
        config.libcrystala_location = "~/crystal/src/ext/libcrystal.a"
        config.path = "/srv/app"
      end

    operation = operation.task__cross_compile__link
    operation.success?.should be_true

    operation.commands.size.should eq(1)

    cmd = operation.commands[0]
    cmd.ssh?.should be_true
    cmd.command_with_arguments.should eq("cc /srv/app ~/crystal/src/ext/libcrystal.a foo")
  end
end