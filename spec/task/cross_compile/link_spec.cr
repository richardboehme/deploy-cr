require "../../spec_helper"
require "../../../src/deploy-cr/deployment"
require "../../../src/deploy-cr/task/cross_compile/compile"
require "../../../src/deploy-cr/task/cross_compile/link"

private class Task < DeployCR::Deployment
  include Task::CrossCompile::Properties

  step Task::CrossCompile::Compile
  step Task::CrossCompile::Link
end

describe DeployCR::Task::CrossCompile::Link do
  it "produce correct commands" do
    CommandStub.stub_command("llvm-command", ["target"])
    CommandStub.stub_command("shards", ["cc #{Path.new(".").expand.join("tmp/deploy")} bar/foo/libcrystal.a foo"])

    operation =
      Task.configure do |config|
        config.user = "user"
        config.host = "host"

        config.llvm_command = "llvm-command"
        config.libcrystala_location = "~/crystal/src/ext/libcrystal.a"
        config.path = "/srv/app"
      end

    operation = operation.task__cross_compile__link
    operation.success?.should be_true

    DeployCR::Command.commands.size.should eq(3)

    cmd = DeployCR::Command.commands.last
    cmd.ssh?.should be_true
    cmd.command_with_arguments.should eq("cc /srv/app ~/crystal/src/ext/libcrystal.a foo")
  end
end