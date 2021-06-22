require "../spec_helper"
require "../../src/deploy-cr/task/compile_assets"

describe DeployCR::Task::CompileAssets do
  it "produce correct output" do
    operation = DeployCR::Task::CompileAssets.run

    operation.commands.size.should eq(2)

    install_command, run_release_command = operation.commands

    install_command.cmd.should eq("npm")
    install_command.args.should eq(["install"])

    run_release_command.cmd.should eq("npm")
    run_release_command.args.should eq(["run", "release"])
  end
end
