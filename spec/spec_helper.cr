require "spec"
require "../src/deploy-cr"
require "hathor-operation"

class DeployCR::Operation < Hathor::Operation
  property commands = [] of DeployCR::Command

  def run(*args, **options)
    commands << build_command(*args, **options)
  end

  def ssh(*args, **options)
    commands << build_command(*args, **options).via_ssh(user, host)
  end
end
