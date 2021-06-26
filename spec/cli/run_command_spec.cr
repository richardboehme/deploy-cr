require "../spec_helper"
require "../../src/deploy-cr/cli/deploy_command"
require "../../src/deploy-cr/cli/init_command"
require "../../src/deploy-cr/cli/run_command"

describe DeployCR::CLI::RunCommand do
  describe "#run" do
    it "require stage" do
      DeployCR::CLI::DeployCommand.run(["run"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/argument is required: STAGE/)
    end

    it "display help" do
      DeployCR::CLI::DeployCommand.run(["run", "--help"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/Deploy your application to the supplied stage/)
      output.should match(/The stage your application should be deployed to/)
    end

    it "run correct command" do
      DeployCR::CLI::DeployCommand.run(["run", "production"])
      DeployCR::Command.commands.size.should eq(1)

      command = DeployCR::Command.commands.last
      command.command_with_arguments.should eq("crystal config/deployment/production.cr --error-trace")
      command.chdir.should eq(Path.new(".").expand)
    end
  end
end