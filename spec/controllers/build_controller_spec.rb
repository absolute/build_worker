require 'spec_helper'  
require 'amazon_cloud/ebs_manager'  
require 'tasks/system_caller'
 
describe BuildController, "#config" do
  context "with valid project" do
    before :each do                                                                                       
      @drive_dir = "/Users/muthu/project/drive/"    
      FileUtils.mkdir_p @drive_dir
      @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake", :ebs_vol=>@drive_dir}
    end
    it "should be successful" do
      SystemCaller.should_receive(:call).any_number_of_times
      post :config, :project=>@project
      @response.should be_success
    end
    it "should attach the EBS volume"  do
      SystemCaller.should_receive(:call).any_number_of_times
      EbsManager.should_receive(:attach_volume).with(@project[:ebs_vol])
      post :config, :project=>@project
    end
    it "should create the environment file" do
      SystemCaller.should_receive(:call).any_number_of_times
      post :config, :project=>@project                        
      File.exists?(@drive_dir+@project[:name]+"/environment.yml").should == true 
    end
    it "should initiate the build" do     
      SystemCaller.should_receive(:call).with(/rake ror:config ENV_FILE='\/Users\/muthu\/project\/drive\/build_worker\/environment.yml' BUILD_ID=/)
      post :config, :project=>@project
    end   
    it "should return the build id" do
      SystemCaller.should_receive(:call).any_number_of_times
      post :config, :project=>@project 
      puts @response.body
      @response.should have_tag("build-id")
    end
    after :each do
      FileUtils.rm_rf @drive_dir
    end
  end
  context "with invalid ebs volume" do
    before :each do                                                                                       
       @drive_dir = "/Users/muthu/project/drive/"    
       FileUtils.mkdir_p @drive_dir
       @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake", :ebs_vol=>@drive_dir}
       SystemCaller.should_receive(:call).any_number_of_times
     end
    it "should fail" do  
      EbsManager.should_receive(:attach_volume).with(@project[:ebs_vol]).and_raise("Invalid EBS Volume")
      post :config, :project=>@project                        
      @response.should_not be_success     
    end
    it "should report the error" do  
      EbsManager.should_receive(:attach_volume).with(@project[:ebs_vol]).and_raise("Invalid EBS Volume")
      post :config, :project=>@project                        
      @response.should have_tag("error-message", :text => "Invalid EBS Volume")
    end
    after :each do
       FileUtils.rm_rf @drive_dir
     end
  end    
end

describe BuildController, "#create" do
  before :each do                                                                                       
    @drive_dir = "/Users/muthu/project/drive/"    
    FileUtils.mkdir_p @drive_dir
    @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake", :ebs_vol=>@drive_dir}
  end
  context "with a commit" do
    it "should be successful" do    
      SystemCaller.should_receive(:call).any_number_of_times
      post :create, :project=>@project, :commit=>"abc123"
      puts @response.body
      @response.should be_success     
    end                                                    
    it "should initiate the build" do
      SystemCaller.should_receive(:call).with(/rake ror:build ENV_FILE='\/Users\/muthu\/project\/drive\/build_worker\/environment.yml' COMMIT='abc123' BUILD_ID=/)
      post :create, :project=>@project, :commit=>"abc123"
    end
    it "should return the build id" do
      SystemCaller.should_receive(:call).any_number_of_times
      post :create, :project=>@project 
      puts @response.body
      @response.should have_tag("build-id")
    end
    it "should return reports url" 
  end                   
  context "without a commit (manual build)" do
    it "should be successful" do    
      SystemCaller.should_receive(:call).any_number_of_times
      post :create, :project=>@project
      puts @response.body
      @response.should be_success     
    end         
    it "should initiate the build" do
      SystemCaller.should_receive(:call).with(/rake ror:build ENV_FILE='\/Users\/muthu\/project\/drive\/build_worker\/environment.yml' BUILD_ID=/)                         
      post :create, :project=>@project
    end
    it "should return build directory"
    it "should return build log url"
    it "should return reports url"
  end
  context "with invalid commit" do
    it "should fail"
    it "should return error"
  end
  after :each do
     FileUtils.rm_rf @drive_dir
  end
end
                              
describe BuildController, "#update" do
  context "with a valid command" do
    it "should run the command"
    it "should restart the build from the failed step"
  end                     
  context "with a invalid command" do
    it "should run the command"
    it "should report error"
  end
end  

describe BuildController, "#delete" do
  context "with a valid build directory" do
    it "should be successful"
    it "should delete the build directory"
  end
  context "with a invalid build directory" do
    it "should fail"
    it "should report the error"
  end
end      

describe BuildController, "#status" do
  before :each do                                                                                       
    @drive_dir = "/Users/muthu/project/drive/"    
    @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake", :ebs_vol=>@drive_dir}
    @build_id = "123"
    FileUtils.mkdir_p @drive_dir+@project[:name]+"/"+@build_id
    File.open(@drive_dir+@project[:name]+"/"+@build_id+"/build.status", 'w') do |out| 
      out.write("running database setup")
    end
  end
  context "with valid build id" do
    it "should be successful" do
      post :status, :project=>@project, :build_id=>@build_id
      @response.should be_success
    end
    it "should return the build status" do
      post :status, :project=>@project, :build_id=>@build_id
      @response.should have_tag("status", :text => "running database setup")
    end
  end                                  
  context "with invalid build id" do
    it "should fail" do
      post :status, :project=>@project, :build_id=>"wrong_build_id"
      @response.should_not be_success
    end
    it "should return error" do
      post :status, :project=>@project, :build_id=>"wrong_build_id"
      @response.should have_tag("error-message")
    end
  end  
  after :each do
     FileUtils.rm_rf @drive_dir
  end
end
