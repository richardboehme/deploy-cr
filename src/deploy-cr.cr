require "deploy-cr/todo"
require "deploy-cr/command"
require "deploy-cr/operation"

# TODO: Write documentation for `Deploy::Cr`
module DeployCR
  VERSION = "0.1.0"
  BINNAME = "deploy"

  def app_path
    Path.new(".").expand
  end

  def app_name_by_path
    app_path.basename
  end

  def tmp_path
    "tmp/deploy"
  end
end
