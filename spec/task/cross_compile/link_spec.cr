require "../../spec_helper"
require "../../../src/deploy-cr/deployment"
require "../../../src/deploy-cr/task/cross_compile/compile"
require "../../../src/deploy-cr/task/cross_compile/link"

private class TestTask < DeployCR::Deployment
  include Task::CrossCompile::Properties

  step Task::CrossCompile::Compile
  step Task::CrossCompile::Link
end

describe DeployCR::Task::CrossCompile::Link do
  it "produce correct commands" do
    CommandStub.stub_command("llvm-command", ["target"])
    {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
    CommandStub.stub_command("shards", ["cc #{Path.new(".").expand.join("tmp/deploy")} bar/foo/libcrystal.a foo"])
    {% else %}
    CommandStub.stub_command("shards", ["cc #{Path.new(".").expand.join("tmp/deploy")} foo"])
    {% end %}

    operation =
      TestTask.configure do |config|
        config.user = "user"
        config.host = "host"

        config.llvm_command = "llvm-command"
        {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
        config.libcrystala_location = "~/crystal/src/ext/libcrystal.a"
        {% end %}
        config.path = "/srv/app"
      end

    operation = operation.task__cross_compile__link
    operation.success?.should be_true

    DeployCR::Command.commands.size.should eq(3)

    cmd = DeployCR::Command.commands.last
    cmd.ssh?.should be_true
    {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
    cmd.command_with_arguments.should eq("cc /srv/app ~/crystal/src/ext/libcrystal.a foo")
    {% else %}
    cmd.command_with_arguments.should eq("cc /srv/app foo")
    {% end %}
  end
end
