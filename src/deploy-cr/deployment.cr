require "hathor-operation"

class DeployCR::Deployment < Hathor::Operation

  property host : String
  property user : String
  property path : String
  property app_name : String
  property source = "local"
  property tmppath = "tmp/deploy"
  property! link_command : String
  property! llvm_target : String
  property! service : String

  def initialize(@host, @user, @path, @app_name = app_name_by_path, @source = "local", @service = app_name); end

  def clone_repository!
    if run_process("mkdir", ["-p", tmppath], chdir: app_path)
      if source == "local"
        run_process("cp", ["-R", app_path, tmppath], chdir: app_path)
      else
        run_process("rm", ["-rf", tmppath + "/"], chdir: app_path) && run_process("git", ["clone", source, tmppath], chdir: app_path)
      end
    end
  end

  def compile_assets!
    run_process("npm", ["install"]) && run_process("npm", ["run", "production"])
  end
  
  def compile_shards!
    run_process("shards", ["install", "--production"])
  end

  def retrieve_llvm_target!
    output = IO::Memory.new
    success = ssh_process("llvm-config --host-target", output)
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
    success = run_process("shards", ["build", app_name, "--release", "--target=#{llvm_target}", "--cross-compile"], IO::MultiWriter.new(output, STDOUT))
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
    run_process("scp", [app_path, "#{user}@#{host}:#{path}"])
  end
  
  def link_binary!
    ssh_process(link_command)
  end
  
  def restart!
    ssh_process("service #{service} restart")
  end

  private def run_process(cmd, args = nil, output = STDOUT, chdir = File.join(app_path, tmppath))
    status = Process.run(cmd, args, output: output, error: STDOUT, chdir: chdir)
    status.success?
  end

  private def ssh_process(cmd, output = STDOUT)
    run_process("ssh", ["#{user}@#{host}", cmd], output)
  end

  private def app_path
    "."
  end

  private def app_name_by_path
    Path.new(app_path).expand.basename
  end

end