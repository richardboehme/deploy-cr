require "./deploy-cr/**"

module DeployCR
  VERSION = "0.2.0"
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

  def self.stdout
    STDOUT
  end

  def self.stderr
    STDOUT
  end
end
