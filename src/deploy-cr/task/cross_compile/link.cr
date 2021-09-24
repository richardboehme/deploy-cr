module DeployCR::Task::CrossCompile
  class Link < DeployCR::Operation
    include Properties

    property path : String


    {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
    def initialize(@user, @host, @path, @link_command, @libcrystala_location); end
    {% else %}
    def initialize(@user, @host, @path, @link_command); end
    {% end %}

    step link_binary!

    def link_binary!
      # processing of the link command
      if command = self.link_command
        command = command.gsub(app_path.join(tmppath).to_s, path)
        {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
        if libcrystala_location
          command = command.gsub(/[^ ]*libcrystal.a[^ ]*/, libcrystala_location)
        end
        {% end %}
        ssh(command)
      else
        false
      end
    end
  end
end
