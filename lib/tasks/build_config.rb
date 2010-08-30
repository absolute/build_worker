class BuildConfig
  attr_reader :project_folder,:build_id,:project_uri,:auth_type,:username,:password,:source_folder,:build_folder,:build_log,:commit_report
  
  def initialize(args)
    @env_file = ""     
    @pwd = Dir.getwd
    @project_folder = "#{pwd}/#{args[:drive]}/#{args[:project_name]}"
    @build_id = args[:build_id]
    @project_uri = args[:project_uri]    
    @auth_type=args[:auth_type]
    @username=args[:username]
    @password=args[:password]
    @source_folder = "#{project_folder}/source"
    @build_folder = "#{project_folder}/#{build_id}"
    @build_log = "#{build_folder}/build.log"
    @commit_report = "#{build_folder}/commit.report"
  end
    
end  
