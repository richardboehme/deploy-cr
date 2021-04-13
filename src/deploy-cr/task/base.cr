require "hathor-operation"

class DeployCR::Task::Base < Hathor::Operation
  property context : DeployCR::Deployment

  def initialize(@context); end

end