require "./properties"

module DeployCR::Task::CrossCompile
  class Compile < DeployCR::Operation
    include Properties

    property app_name : String
    property files : Array(String)

    def initialize(@user, @host, @app_name, @files, @llvm_command, @link_command = nil); end

    step retrieve_llvm_target!
    step compile_app!

    def retrieve_llvm_target!
      output = IO::Memory.new
      success = ssh(llvm_command, ["--host-target"], output: output)
      if success
        output.rewind
        self.llvm_target = output.read_line
      end
    end

    def compile_app!
      output = IO::Memory.new
      # When adding --progress nothing is logged to stdout and the deployment does not work.
      # The solution would be that the crystal build command sets STDOUT.sync = true
      success = run("shards", ["build", app_name, "--release", "--production", "--target=#{llvm_target}", "--cross-compile"], output: IO::MultiWriter.new(output, DeployCR.stdout), shell: true)
      if success
        output.rewind
        output.each_line do |line|
          if line.starts_with?("cc")
            self.link_command = line
            self.files << "bin/#{app_name}.o"
            return true
          end
        end
      end
    end
  end
end