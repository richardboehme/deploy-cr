module DeployCR::Task::CrossCompile
  class Link < DeployCR::Operation
    include Properties

    property path : String

    def initialize(@user, @host, @path, @link_command, @libcrystala_location); end

    step link_binary!

    def link_binary!
      # processing of the link command
      if command = self.link_command
        command = command.gsub(app_path.join(tmppath).to_s, path)
        if libcrystala_location
          # FIXME: can we instead pass a custom compile flag that defines this?
          command = command.gsub(/[^ ]*libcrystal.a[^ ]*/, libcrystala_location)
        end
        ssh(command)
      else
        false
      end
    end
  end
end