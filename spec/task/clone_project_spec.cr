require "../spec_helper"
require "../../src/deploy-cr/deployment"
require "../../src/deploy-cr/task/clone_project"

private class Task < DeployCR::Deployment
  include Task::CloneProject::Properties

  step Task::CloneProject
end

describe DeployCR::Task::CloneProject do
  it "produce correct output" do
    operation =
      Task.configure do |config|
        config.source = "git-repo"
      end

    operation = operation.task__clone_project
    operation.success?.should be_true

    DeployCR::Command.commands.size.should eq(3)

    cmd = DeployCR::Command.commands[0]
    cmd.cmd.should eq("mkdir")
    cmd.args.should eq(["-p", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))

    cmd = DeployCR::Command.commands[1]
    cmd.cmd.should eq("rm")
    cmd.args.should eq(["-rf", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))

    cmd = DeployCR::Command.commands[2]
    cmd.cmd.should eq("git")
    cmd.args.should eq(["clone", "--recurse-submodules", "git-repo", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))
  end
end
