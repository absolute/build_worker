class BuildController < ApplicationController
                                          
# POST /build/config/:project_name.xml
def config                     
  @project = params[:project]  
  @build_id = create_build_id      
  FileUtils.mkdir_p project_folder
  FileUtils.mkdir_p project_folder+"/"+@build_id
  EbsManager.attach_volume(@project[:ebs_vol])           
  create_env_file
  system("rake ror:config ENV_FILE='#{project_folder}environment.yml' BUILD_ID='#{@build_id}'")  
  respond_to do |format|
    format.xml { render :xml => {:build_id => @build_id, :status=>"building"}} 
  end       
rescue => e
  respond_to do |format|
    format.xml { render :xml => {:error_message=>"#{e}"}, :status=>500} 
  end
end                                           
      
def create_env_file
  env = {"project"=>@project, "project_folder"=>project_folder}
  File.open(project_folder+"environment.yml", 'w') do |out|
      YAML.dump(env, out) 
  end       
end
        
def project_folder
  @project[:ebs_vol]+@project[:name].gsub(/\s/,"-")+"/"
end
                                                   
def create_build_id
  @build_id = @build_id || Time.new.to_f.to_s
end
  
# POST /build/:project_name.xml                                                                       
def create   
    @project = params[:project]
    @build_id = create_build_id      
    FileUtils.mkdir_p project_folder+"/"+@build_id
    EbsManager.attach_volume(@project[:ebs_vol])           
    cmd = "rake ror:build ENV_FILE='#{project_folder}environment.yml' "
    cmd +=  "COMMIT='#{params[:commit]}' " if params[:commit]    
    cmd +=  "BUILD_ID='#{@build_id}'"
    system(cmd)  
    respond_to do |format|
      format.xml { render :xml => {:build_id => @build_id, :status=>"building"}} 
    end       
  rescue => e
    respond_to do |format|
      format.xml { render :xml => {:error_message=>"#{e}"}, :status=>500} 
    end
end
   
# PUT /build/:project_name/:build_id.xml
def update
end
                                     
# GET /build/:project_name/:build_id.xml
def status      
  @project = params[:project] 
  @build_id = params[:build_id] 
  status = IO.read(project_folder+@build_id+"/build.status")
  respond_to do |format|
    format.xml {render :xml => {:status => "#{status}"}}
  end
rescue => e
  respond_to do |format|
    format.xml {render :xml => {:error_message=>"#{e}"}, :status=>500}
  end
end 

# DELETE /build/:project_name/:build_id.xml
def delete
end

end
