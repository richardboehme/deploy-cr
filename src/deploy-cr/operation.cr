require "hathor-operation"

class DeployCR::Operation < Hathor::Operation
  include DeployCR

  property tmppath = "tmp/deploy"
  property! user : String
  property! host : String

  def self.configure
    operation = self.new
    yield operation
    operation.run
  end

  def run(*args, **options)
    build_command(*args, **options).run
  end

  def ssh(*args, **options)
    build_command(*args, **options).via_ssh(user, host).run
  end

  private def build_command(*args, **options)
    DeployCR::Command.new(*args, **options)
  end

  @[Deprecated("Use `#run` instead")]
  def run_process(cmd, args = nil, output = DeployCR.stdout, chdir = File.join(app_path, tmppath), shell = false)
    puts "RUNNING (shell: #{shell}): #{cmd} #{args ? args.join(" ") : nil}"

    status = Process.run(cmd, args, output: output, error: DeployCR.stderr, chdir: chdir.to_s, shell: shell)
    status.success?
  end

  @[Deprecated("Use `#ssh` instead")]
  private def ssh_process(cmd, output = DeployCR.stdout)
    run_process("ssh", ["#{user}@#{host}", cmd], output)
  end
end
