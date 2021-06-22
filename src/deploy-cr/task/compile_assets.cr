module DeployCR::Task
  class CompileAssets < DeployCR::Operation
    step npm_install!
    step build_bundle!

    def npm_install!
      run("npm", ["install"])
    end

    def build_bundle!
      run("npm", ["run", "release"])
    end
  end
end
