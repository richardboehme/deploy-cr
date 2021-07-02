require "./operation"

class DeployCR::Deployment < DeployCR::Operation
  property! path : String
  property app_name : String
  property files = [] of String

  def initialize(
    @app_name = app_name_by_path
  ); end

  def sync_to_server!
    # we need to use shell option here because otherwise * would not expand correctly
    run(
      "rsync",
      [
        "-avmz",
        "--include=\"*/\"",
        files.map{ |file| "--include=\"#{file}\"" },
        "--exclude=\"*\"",
        ".",
        "#{user}@#{host}:#{path}"
      ].flatten,
      shell: true
    )
  end
end
