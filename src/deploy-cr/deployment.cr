require "hathor-operation"
require "./task/compile_assets"

class DeployCR::Deployment < Hathor::Operation

  property host : String
  property user : String
  property path : String
  property app_name : String
  property source = "local"
  property llvm_command : String
  property tmppath = "tmp/deploy"
  property libcrystala_location : String?
  property files_to_upload : Array(String)
  property! link_command : String
  property! llvm_target : String
  property! service : String

  def initialize(
    @host,
    @user,
    @path,
    @libcrystala_location,
    @llvm_command = "llvm-config",
    @app_name = app_name_by_path,
    @source = "local",
    @service = app_name,
    @files_to_upload = ["bin/#{app_name}.o", "config/environments/.production.enc", "config/database.yml"]
  ); end

  def clone_repository!
    if run_process("mkdir", ["-p", tmppath], chdir: app_path)
      if source == "local"
        run_process("cp", ["-R", app_path.to_s, tmppath], chdir: app_path)
      else
        run_process("rm", ["-rf", tmppath + "/"], chdir: app_path) && run_process("git", ["clone", source, tmppath], chdir: app_path)
      end
    end
  end

  def compile_assets!
    DeployCR::Task::CompileAssets.run(self).success?
  end
  
  def compile_shards!
    run_process("shards", ["install", "--production"])
  end

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
    success = run_process("shards", ["build", app_name, "--release", "--target=#{llvm_target}", "--cross-compile", "--progress"], IO::MultiWriter.new(output, STDOUT))
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
      self.link_command = link_command.gsub(/ [^ ]*libcrystal.a[^ ]* /, libcrystala_location)
    end
    ssh_process(link_command)
  end
  
  def restart!
    ssh_process("service #{service} restart")
  end

  def run_process(cmd, args = nil, output = STDOUT, chdir = File.join(app_path, tmppath), shell = false)
    puts "RUNNING (shell: #{shell}): #{cmd} #{args ? args.join(" ") : nil}"

    status = Process.run(cmd, args, output: output, error: STDOUT, chdir: chdir.to_s, shell: shell)
    status.success?
  end

  private def ssh_process(cmd, output = STDOUT)
    run_process("ssh", ["#{user}@#{host}", cmd], output)
  end

  private def app_path
    Path.new(".").expand
  end

  private def app_name_by_path
    app_path.basename
  end

end