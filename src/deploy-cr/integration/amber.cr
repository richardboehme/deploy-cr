module DeployCR::Integration
  class Amber < DeployCR::Operation
    property files : Array(String)

    def initialize(@files); end

    step apply_defaults!

    def apply_defaults!
      files << "config/environments/.production.enc"
      files << "config/database.yml"
      files << "public/**/**"
    end
  end
end