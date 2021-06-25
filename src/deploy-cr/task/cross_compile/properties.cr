module DeployCR::Task::CrossCompile::Properties
  property llvm_command = "llvm-config"
  property libcrystala_location : String?
  property llvm_target : String?
  property! link_command : String
end