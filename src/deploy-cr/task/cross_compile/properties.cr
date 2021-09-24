module DeployCR::Task::CrossCompile::Properties
  property llvm_command = "llvm-config"
  {% if compare_versions(Crystal::VERSION, "1.1.0-0") < 0 %}
  property libcrystala_location : String?
  {% end %}
  property llvm_target : String?
  property link_command : String?
end
