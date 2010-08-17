require "spec_helper"

describe "ror", "#new project" do  
  before (:all) do
      @drive_dir = "/Users/muthu/project/ror_unitest"
      @project_uri = "git://github.com/absolute/build_worker.git"
      @project_name = "build_worker"    
      @build_dir = "/Users/muthu/project/builds"
  end
  context "checkout on an empty drive" do     
    before (:each) do    
      FileUtils.mkdir_p @drive_dir
    end
    it "should end successfully" do  
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      $?.success?.should == true
    end
    it "should checkout from repository" do            
      Dir.entries("#{@drive_dir}").select {|n| n =~ /^\w/}.should be_empty
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      Dir.entries("#{@drive_dir}").select {|n| n =~ /^\w/}.should_not be_empty    
    end                                                  
    after (:each) do
      FileUtils.rm_rf @drive_dir
    end
  end                                 
  context "checkout on a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@drive_dir}/#{@project_name}/tmp"
    end
    it "should fail" do                                                             
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      $?.success?.should == false      
    end    
    it "should report 'destination already exists' error" do
      system(%{rake ror:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      File.new("error.log").readlines(nil)[0].should match(/.*destination.*already.*exists.* /)
    end
    after (:each) do    
      FileUtils.rm_rf @drive_dir
    end
  end
end
  
describe "ror", "#existing project" do
  before (:all) do
      @drive_dir = "/Users/muthu/project/ror_unitest/"
      @project_uri = "git://github.com/absolute/build_worker.git"
      @project_name = "build_worker/"    
      @build_dir = "/Users/muthu/project/builds/"
      @commit_report = "commit.report"
  end
  context "update on an empty drive" do   
    before (:each) do
      FileUtils.mkdir_p @drive_dir
    end
    it "should fail" do
      system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} 2>error.log 1>out.log})
      $?.success?.should == false 
    end                           
    it "show report 'No such file or directory ' error" do
      system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} 2>error.log 1>out.log})
      File.new("error.log").readlines(nil)[0].should match(/.*No.such.file.or.directory.*/)
    end  
    after (:each) do
      FileUtils.rm_rf @drive_dir
    end
  end  
  context "update on a NON-empty drive" do
    before (:all) do
      FileUtils.mkdir_p @drive_dir                      
      Dir.chdir("#{@drive_dir}") do 
        system %{git clone #{@project_uri} #{@project_name}}
        Dir.chdir("#{@project_name}") do
          system %{git reset --hard 1d83c209d0233667b2ab50cc82c1a2f008999b16}
        end
      end
    end
    context "with same project in drive" do
      it "should be successfull" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        $?.success?.should == true
      end
      it "should return commit id" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report}})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
      end
      it "should return commit by" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)
      end
      it "should return commit on" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)
      end
      it "should return commit message" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*commit_message:.*/)
      end
      it "should return changed files" do
        system(%{rake ror:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*changed_files:.*/)
      end
    end
    context "with an invalid repository" do
      it "should return error details"
    end                       
    after (:all) do
      FileUtils.rm_rf @drive_dir
    end
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
