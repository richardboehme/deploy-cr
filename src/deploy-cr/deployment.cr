class DeployCR::Deployment < DeployCR::Operation
  property! path : String
  property app_name : String
  property llvm_command : String
  property libcrystala_location : String?
  property files_to_upload : Array(String)
  property! link_command : String
  property! llvm_target : String
  property! service : String

  def initialize(
    @llvm_command = "llvm-config",
    @app_name = app_name_by_path,
    @service = app_name,
    @files_to_upload = ["bin/#{app_name}.o", "config/environments/.production.enc", "config/database.yml"]
  ); end

  def retrieve_llvm_target!
    output = IO::Memory.new
    success = ssh_process("#{llvm_command} --host-target", output)
    if success
      output.rewind
      self.llvm_target = output.read_line
    else
      # Somehow ssh seems to ouput some errors to the stdout instead of error stream
      output.rewind
      output.each_line do |line|
        puts line
      end
      false
    end
  end

  def compile_app!
    output = IO::Memory.new
    # When adding --progress nothing is logged to stdout and the deployment does not work.
    # The solution would be that the crystal build command sets STDOUT.sync = true
    success = run_process("shards", ["build", app_name, "--release", "--production", "--target=#{llvm_target}", "--cross-compile"], IO::MultiWriter.new(output, STDOUT), shell: true)
    if success
      output.rewind
      output.each_line do |line|
        if line.starts_with?("cc")
          self.link_command = line
          return true
        end
      end
    end
  end

  def sync_to_server!
    # we need to use shell option here because otherwise * would not expand correctly
    # rsync -avmz -e ssh --include=files_to_upload.first --include=files_to_upload.second [...] --exclude="*"
    run_process("rsync -avmz -e ssh --include=\"*/\" #{files_to_upload.map { |file| "--include=\"#{file}\"" }.join(" ")} --exclude=\"*\" . #{user}@#{host}:#{path}", shell: true)
  end

  def link_binary!
    # processing of the link command
    self.link_command = link_command.gsub(app_path.join(tmppath).to_s, path)
    if libcrystala_location
      # FIXME: can we instead pass a custom compile flag that defines this?
      self.link_command = link_command.gsub(/[^ ]*libcrystal.a[^ ]*/, libcrystala_location)
    end
    ssh_process(link_command)
  end

  def restart!
    ssh_process("systemctl --user restart #{service}")
  end
end
