require "../spec_helper"
require "../../src/deploy-cr/cli/deploy_command"
require "../../src/deploy-cr/cli/run_command"
require "../../src/deploy-cr/cli/init_command"

describe DeployCR::CLI::DeployCommand do
  describe ".run" do
    it "display help when option passed" do
      DeployCR::CLI::DeployCommand.run(["--help"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/DeployCR is a tool to deploy crystal applications to a server/)
    end

    it "display help on parse error" do
      DeployCR::CLI::DeployCommand.run(["--unknown"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/no such command --unknown/)
    end

    it "have init command" do
      DeployCR::CLI::DeployCommand.run(["init", "--help"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/Initialize your project with deployment settings/)
    end

    it "have run command" do
      DeployCR::CLI::DeployCommand.run(["run", "--help"])
      DeployCR.stdout.rewind
      output = DeployCR.stdout.gets_to_end
      output.should match(/Deploy your application to the supplied stage/)
    end
  end
end