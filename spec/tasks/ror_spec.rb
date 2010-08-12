require "spec_helper"
require "file_helper"
                      
include FileHelper

describe "ror", "#checkout new project" do
  context "on an empty drive" do     
    before (:each) do
      @drive_dir = "/Users/muthu/project/ror_unitest"
      @project_uri = "git://github.com/absolute/build_worker.git"
      @project_name = "build_worker"
      recreate_dir @drive_dir
    end
    it "should end successfully" do  
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      $?.success?.should == true
    end
    it "should checkout from repository" do  
      Dir["#{@drive_dir}/*"].empty?.should == true
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      Dir["#{@drive_dir}/*"].empty?.should == false
    end   
  end                                 
  context "on a NON-empty drive" do
    it "should fail" do
      @drive_dir = "/Users/muthu/project/ror_unitest"
      @project_uri = "git://github.com/absolute/build_worker.git"
      @project_name = "build_worker"   
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      $?.success?.should == false
    end
  end
end
  
describe "ror", "#update existing project" do
  context "on an empty drive" do
    it "should fail"
  end  
  context "on a NON-empty drive" do
    context "with correct project" do
    it "should get latest from repository"
    it "should return author"
    it "should return commit message"
    it "should return changed files list"
    end
  end
  context "with an invalid repository" do
    it "should return error details"
  end                       

end  

describe "ror", "#database_setup" do
  context "with database file in the project" do
    it "should delete the database file"
    it "should create a symbolic link to the worker's database file"
  end
  context "with NO database file in the project" do
    it "should NOT create a symbolic link to the worker's database file"
  end     
end

describe "ror", "#build" do
  context "with no dependencies" do
    it "should create a build folder"           
    it "should create a build log in the build folder"
    it "should create the build reports in build folder"
    it "should report success in the build status file"
  end
  context "with dependencies NOT met" do
    it "should create a build folder"
    it "should create a build log in the build folder"
    it "should report error in the build status file"
  end
end
