class BuildController < ApplicationController
                                          
# POST /build/config/:project_name.xml
def config                     
  @project = params[:project]
  FileUtils.mkdir_p project_folder
  env = {"project"=>@project, "project_folder"=>project_folder}
  File.open(project_folder+"environment.yml", 'w') do |out|
      YAML.dump(env, out) 
  end       
  EbsManager.attach_volume(@project[:ebs_vol])           
  system("rake ror:build")  
  respond_to do |format|
    format.xml { render :xml => {:status=>"building"}} 
  end       
rescue
  respond_to do |format|
    format.xml { render :xml => {:error_no => 100, :error_message=>"invalid ebs volume"}, :status=>500} 
  end
end                                           

def project_folder
  @project[:ebs_vol]+@project[:name].gsub(/\s/,"-")+"/"
end
  
# POST /build/:project_name.xml
def create
  respond_to do |format|
    format.xml { render :xml => {:status => "building", :build_id => 1, :reports_url => "http://aws.amazon.com/1/reports"}}
  end
end
   
# PUT /build/:project_name/:build_id.xml
def update
end
                                     
# GET /build/:project_name/:build_id.xml
def status
  respond_to do |format|
    format.xml {render :xml => {:status => "building"}}
  end
end 

# DELETE /build/:project_name/:build_id.xml
def delete
end

end
