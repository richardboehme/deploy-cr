require "../spec_helper"
require "../../src/deploy-cr/cli/deploy_command"
require "../../src/deploy-cr/cli/run_command"
require "../../src/deploy-cr/cli/init_command"

module DeployCR::CLI
  struct InitCommand < DeployCommand
    class Template < Teeplate::FileTree
      @@calls = [] of NamedTuple(list: Bool, color: Bool, interactive: Bool)

      def render(out_dir, **options)
        @@calls << options
        super("tmp/templates", force: true)
      end

      def self.calls
        @@calls
      end
    end
  end
end

describe DeployCR::CLI::InitCommand do
  describe "#run" do
    it "only allows cross compile" do
      expect_raises(TODO, /normal compile mode\) is not implemented yet/) do
        DeployCR::CLI::InitCommand.run(["init"])
      end
    end

    it "set correct teeplate options" do
      DeployCR::CLI::InitCommand.run(["init", "--cross-compile"])
      options = DeployCR::CLI::InitCommand::Template.calls.last
      options[:interactive].should be_true
      options[:color].should be_true
      options[:list].should be_true
    end

    it "generate correct stage file" do
      DeployCR::CLI::InitCommand.run(["init", "--cross-compile"])
      path = File.join("tmp", "templates", "config", "deployment", "production.cr")
      File.file?(path).should be_true
      content = File.read(path)

      content.should match(Regex.new("^require \"\.\/task\"$", Regex::Options::MULTILINE))
      content.should match(/^Deployment::Task\.configure do \|config\|$/m)
      content.should match(/^end$/m)
    end

    it "generate with cross compile option" do
      DeployCR::CLI::InitCommand.run(["init", "--cross-compile"])
      path = File.join("tmp", "templates", "config", "deployment", "task.cr")
      File.file?(path).should be_true
      content = File.read(path)

      content.should match(Regex.new("^require \"deploy-cr\/deployment\"$", Regex::Options::MULTILINE))
      content.should match(/^class Deployment::Task < DeployCR::Deployment$/m)
      content.should match(/^  include Task::CloneProject::Properties$/m)
      content.should match(/^  include Task::CrossCompile::Properties$/m)
      content.should match(/^end$/m)

      steps = steps_by_file(content)
      steps.next.should eq("Task::CloneProject")
      steps.next.should eq("Task::CrossCompile::Compile")
      steps.next.should eq("sync_to_server!")
      steps.next.should eq("Task::CrossCompile::Link")
      steps.next.should eq(Iterator::Stop::INSTANCE)
    end

    it "generate with npm option" do
      DeployCR::CLI::InitCommand.run(["init", "--npm", "--cross-compile"])
      path = File.join("tmp", "templates", "config", "deployment", "task.cr")
      File.file?(path).should be_true
      content = File.read(path)

      steps = steps_by_file(content)
      steps.next.should eq("Task::CloneProject")
      steps.next.should eq("Task::CompileAssets")
      steps.next.should eq("Task::CrossCompile::Compile")
      steps.next.should eq("sync_to_server!")
      steps.next.should eq("Task::CrossCompile::Link")
      steps.next.should eq(Iterator::Stop::INSTANCE)
    end

    it "generate with amber option" do
      DeployCR::CLI::InitCommand.run(["init", "--amber", "--cross-compile"])
      path = File.join("tmp", "templates", "config", "deployment", "task.cr")
      File.file?(path).should be_true
      content = File.read(path)

      steps = steps_by_file(content)
      steps.next.should eq("Task::CloneProject")
      steps.next.should eq("Task::CrossCompile::Compile")
      steps.next.should eq("Integration::Amber")
      steps.next.should eq("sync_to_server!")
      steps.next.should eq("Task::CrossCompile::Link")
      steps.next.should eq(Iterator::Stop::INSTANCE)
    end
  end
end


def steps_by_file(content)
  content.split("\n").map do |line|
    if match = line.match(/step (.*)/)
      match[1]
    end
  end.compact.each
end
