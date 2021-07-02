class DeployCR::Command
  include DeployCR

  property cmd : String
  property args
  property output : IO
  property chdir : Path
  property? shell
  property! status : Process::Status

  def initialize(
    @cmd,
    @args = [] of String,
    @output = DeployCR.stdout,
    @chdir = Path[File.join(app_path, tmp_path)],
    @shell = false
  )
  end

  def run
    arguments = self.args
    command = self.cmd
    if self.shell? && self.args
      arguments = nil
      command += " #{self.args.join(" ")}"
    end

    self.status =
      Process.run(
        command,
        arguments,
        output: @output,
        error: DeployCR.stderr,
        chdir: @chdir.to_s,
        shell: @shell
      )
    self.status.success?
  end

  def via_ssh(user, host)
    @args = ["#{user}@#{host}", cmd, args].flatten
    @cmd = "ssh"
    self
  end

  def ssh?
    @cmd == "ssh"
  end

  def real_command
    ssh? ? args[1] : cmd
  end

  def real_arguments
    ssh? ? args[2..-1] : args
  end

  def command_with_arguments
    [real_command, real_arguments].flatten.join(" ")
  end
end
