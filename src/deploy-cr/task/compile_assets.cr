require "./base"

module DeployCR::Task
  class CompileAssets < Base
    
    step npm_install!
    step build_bundle!


    def npm_install!
      context.run_process("npm", ["install"])
    end

    def build_bundle!
      context.run_process("npm", ["run", "release"])
    end

  end
end