require "spec"
require "../src/deploy-cr"
require "hathor-operation"

SPEC_STDOUT = IO::Memory.new

module DeployCR
  def self.stdout
    SPEC_STDOUT
  end
end

Spec.after_each do
  DeployCR.stdout.clear
end

class CommandStub
  @@stubs = {} of String => Array(String)

  def self.stub_command(cmd, outputs)
    @@stubs[cmd] = outputs
  end

  def self.stubs
    @@stubs
  end
end

class DeployCR::Operation < Hathor::Operation
  property commands = [] of DeployCR::Command

  def run(*args, **options)
    commands << build_command(*args, **options)
    true
  end

  def ssh(*args, **options)
    commands << build_command(*args, **options).via_ssh(user, host)
    true
  end

  def build_command(*args, **options)
    command = DeployCR::Command.new(*args, **options)
    if command.output != STDOUT && CommandStub.stubs.has_key? command.cmd
      CommandStub.stubs[command.cmd].each do |line|
        command.output.puts(line)
      end
    end
    command
  end
end
