require "../spec_helper"
require "../../src/deploy-cr/deployment"
require "../../src/deploy-cr/integration/amber"

private class Task < DeployCR::Deployment
  step Integration::Amber
end

describe DeployCR::Integration::Amber do
  it "produce correct output" do
    operation = Task.run

    operation = operation.integration__amber
    operation.success?.should be_true
    operation.files.includes?("public/**/**").should be_true
    operation.files.includes?("config/environments/.production.enc").should be_true
    operation.files.includes?("config/database.yml").should be_true
  end
end
