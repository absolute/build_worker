class BuildConfig
  attr_reader :worker_folder, :project_folder,:build_id,:project_uri,:auth_type,:username,:password,:source_folder,
          :build_folder,:build_log,:commit_report,:ssh_folder_from, :ssh_folder_to, :ssh_config_from, :ssh_config_to, 
          :ssh_private_key_from, :ssh_private_key_to,:ssh_public_key_from, :ssh_public_key_to
  
  def initialize(args)
    @env_file = ""     
    @worker_folder = args[:worker_folder]
    @project_folder = "#{@worker_folder}/#{args[:drive]}/#{args[:project_name]}"
    @build_id = args[:build_id]
    @project_uri = args[:project_uri]    
    @auth_type=args[:auth_type]
    @username=args[:username]
    @password=args[:password]
    @source_folder = "#{project_folder}/source"
    @build_folder = "#{project_folder}/#{build_id}"
    @build_log = "#{build_folder}/build.log"
    @commit_report = "#{build_folder}/commit.report"  
                                            
    if args[:ssh_folder_to]
      @ssh_folder_to = args[:ssh_folder_to]
      @ssh_folder_from = "#{worker_folder}/for_builds/sshkeys"
      @ssh_config_from = "#{ssh_folder_from}/ssh_config"
      @ssh_config_to = "#{ssh_folder_to}/config"
      @ssh_private_key_from = "#{ssh_folder_from}/id_rsa.pureapp"
      @ssh_private_key_to = "#{ssh_folder_to}/id_rsa.pureapp"
      @ssh_public_key_from = "#{ssh_folder_from}/id_rsa.pureapp.pub"
      @ssh_public_key_to = "#{ssh_folder_to}/id_rsa.pureapp.pub"                
    end
    
  end
    
end  
