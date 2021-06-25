class DeployCR::Deployment < DeployCR::Operation
  property! path : String
  property app_name : String
  property files = [] of String

  def initialize(
    @app_name = app_name_by_path
  ); end

  def sync_to_server!
    # we need to use shell option here because otherwise * would not expand correctly
    # rsync -avmz -e ssh --include=files_to_upload.first --include=files_to_upload.second [...] --exclude="*"
    run_process("rsync -avmz -e ssh --include=\"*/\" #{files.map { |file| "--include=\"#{file}\"" }.join(" ")} --exclude=\"*\" . #{user}@#{host}:#{path}", shell: true)
  end
end
