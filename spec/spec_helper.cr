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
  DeployCR::Command.commands.clear
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

class DeployCR::Command
  @@commands = [] of DeployCR::Command

  def run
    @@commands << self
    if self.output != STDOUT && CommandStub.stubs.has_key? self.real_command
      CommandStub.stubs[self.real_command].each do |line|
        self.output.puts(line)
      end
    end
    true
  end

  def self.commands
    @@commands
  end
end
