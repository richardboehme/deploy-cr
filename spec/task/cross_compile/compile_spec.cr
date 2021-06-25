require "../../spec_helper"
require "../../../src/deploy-cr/deployment"
require "../../../src/deploy-cr/task/cross_compile/compile"

private class Task < DeployCR::Deployment
  include Task::CrossCompile::Properties

  step Task::CrossCompile::Compile
end

describe DeployCR::Task::CrossCompile::Compile do
  it "produce correct commands" do
    CommandStub.stub_command("llvm-command", ["target"])
    CommandStub.stub_command("shards", ["cc linking"])

    base_operation =
      Task.configure do |config|
        config.user = "user"
        config.host = "host"

        config.llvm_command = "llvm-command"
      end

    operation = base_operation.task__cross_compile__compile
    operation.success?.should be_true

    operation.commands.size.should eq(2)

    cmd = operation.commands[0]
    cmd.ssh?.should be_true
    cmd.command_with_arguments.should eq("llvm-command --host-target")

    cmd = operation.commands[1]
    cmd.command_with_arguments.should eq("shards build deploy-cr --release --production --target=target --cross-compile")
    cmd.output.class.should eq(IO::MultiWriter)

    operation.link_command.should eq("cc linking")
    base_operation.files.includes?("bin/deploy-cr.o").should be_true
  end
end