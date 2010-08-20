require 'spec_helper'  
require 'amazon_cloud/ebs_manager'
         
module Kernel                          
    def delete_system_output_file
      File.delete("kernel_system.out") if File.exists?("kernel_system.out")
    end
    def system(cmd)                          
      File.open("kernel_system.out", 'a') do |out| 
        out.write(cmd)
      end
    end       
end                                 

describe BuildController, "#config" do
  context "with valid project" do
    before :each do                                                                                       
      @drive_dir = "/Users/muthu/project/drive/"    
      FileUtils.mkdir_p @drive_dir
      @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake", :ebs_vol=>@drive_dir}
      Kernel.delete_system_output_file
    end
    it "should be successful" do
      post :config, :project=>@project
      @response.should be_success
    end
    it "should attach the EBS volume"  do
      EbsManager.should_receive(:attach_volume).with(@project[:ebs_vol])
      post :config, :project=>@project
    end
    it "should create the environment file" do
      post :config, :project=>@project                        
      File.exists?(@drive_dir+@project[:name]+"/environment.yml").should == true 
    end
    it "should initiate the build" do     
      post :config, :project=>@project
      IO.read("kernel_system.out").should match(/rake ror:build/)                         
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
       Kernel.delete_system_output_file
     end
    it "should report the error" do  
      EbsManager.should_receive(:attach_volume).with(@project[:ebs_vol]).and_raise("Error")
      post :config, :project=>@project                        
      @response.should_not be_success     
    end
    after :each do
       FileUtils.rm_rf @drive_dir
     end
  end    
end

describe BuildController, "#create" do
  context "with a commit" do
    it "should be successful" do    
      post :create, :project=>{:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake"}
      @response.should be_success
    end                                                   
    it "should initiate the build" do
      post :create, :project=>{:id=>1}      
      @response.should have_tag("status", :text => "building")
    end
    it "should return reports url" do
      post :create, :project=>{:id=>1}      
      @response.should have_tag("reports-url", :text => "http://aws.amazon.com/1/reports")
    end
  end                   
  context "without a commit (manual build)" do
    it "should be successful"         
    it "should initiate the build"  
    it "should return 'building status"
    it "should return build directory"
    it "should return build log url"
    it "should return reports url"
  end
  context "with invalid commit" do
    it "should fail"
    it "should return error"
  end
end
                              
describe BuildController, "#update" do
  context "with a valid command" do
    it "should be successful"
    it "should restart the same build"
  end                     
  context "with a invalid command" do
    it "should fail"
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
  context "with a valid build id" do
    it "should be successful"
    it "should return the build status" do
      post :status, :project=>{:id=>1}
      @response.should have_tag("status", :text => "building")
    end
  end                                  
  context "with a invalid build id" do
    it "should fail"
    it "should return error"
  end
end
