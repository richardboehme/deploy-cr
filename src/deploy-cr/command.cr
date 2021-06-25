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
    self.status =
      Process.run(
        @cmd,
        @args,
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

  def command_with_arguments
    if ssh?
      args[1..-1].join(" ")
    else
      [cmd, args].flatten.join(" ")
    end
  end
end
