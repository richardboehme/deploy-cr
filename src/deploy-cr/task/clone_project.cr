module DeployCR::Task
  class CloneProject < DeployCR::Operation
    module Properties
      property! source : String
    end

    include Properties

    def initialize(@source); end

    step create_directory!
    step remove_old_directory!
    step clone_repository!

    def create_directory!
      run("mkdir", ["-p", tmp_path], chdir: app_path)
    end

    def remove_old_directory!
      run("rm", ["-rf", tmp_path], chdir: app_path)
    end

    def clone_repository!
      run("git", ["clone", "--recurse-submodules", source, tmp_path], chdir: app_path)
    end
  end
end
