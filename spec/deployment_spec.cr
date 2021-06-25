require "./spec_helper"
require "../src/deploy-cr/deployment"

private class Task < DeployCR::Deployment
  step sync_to_server!
end

describe DeployCR::Deployment do
  it "produce correct output" do
    operation =
      Task.configure do |config|
        config.user = "user"
        config.host = "host"
        config.path = "/srv/app"

        config.files << "file1"
        config.files << "file2"
      end

    operation.success?.should be_true
    operation.app_name.should eq("deploy-cr")

    operation.commands.size.should eq(1)

    cmd = operation.commands.first
    cmd.shell?.should be_true
    cmd.command_with_arguments.should eq(
      "rsync -avmz -e ssh --include=\"*/\" --include=\"file1\" --include=\"file2\" --exclude=\"*\" . user@host:/srv/app"
    )
  end
end