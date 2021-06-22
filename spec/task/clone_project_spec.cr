require "../spec_helper"
require "../../src/deploy-cr/deployment"
require "../../src/deploy-cr/task/clone_project"

class Task < DeployCR::Deployment
  include DeployCR::Task::CloneProject::Properties

  step DeployCR::Task::CloneProject
end

describe DeployCR::Task::CloneProject do
  it "produce correct output" do
    operation =
      Task.configure do |config|
        config.source = "git-repo"
      end

    operation = operation.deploy_cr__task__clone_project
    operation.success?.should be_true

    operation.commands.size.should eq(3)

    cmd = operation.commands[0]
    cmd.cmd.should eq("mkdir")
    cmd.args.should eq(["-p", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))

    cmd = operation.commands[1]
    cmd.cmd.should eq("rm")
    cmd.args.should eq(["-rf", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))

    cmd = operation.commands[2]
    cmd.cmd.should eq("git")
    cmd.args.should eq(["clone", "--recurse-submodules", "git-repo", "tmp/deploy"])
    cmd.chdir.to_s.should eq(File.join(operation.app_path))
  end
end
