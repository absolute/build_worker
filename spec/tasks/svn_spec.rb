require "spec_helper"

describe "svn", "#new project" do  
  before (:all) do
      @drive_dir = "/Users/muthu/project/svn_unittest/"
      @project_uri = "http://indiaserver.no-ip.info/repo/dummy/trunk"
      @project_name = "dummy/"    
      @build_dir = "/Users/muthu/project/builds/1/"
  end
  context "checkout on an empty drive" do     
    before (:each) do    
      FileUtils.mkdir_p @drive_dir
    end
    it "should end successfully" do  
      system(%{rake svn:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      $?.success?.should == true
    end
    it "should checkout from repository" do            
      Dir.entries("#{@drive_dir}").select {|n| n =~ /^\w/}.should be_empty
      system(%{rake svn:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
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
      pending ("svn doesn't report error if trying to checkout for second time")
      system(%{rake svn:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri}})    
      $?.success?.should == false      
    end    
    it "should report 'destination already exists' error" do
      pending ("svn doesn't report error if trying to checkout for second time")
      system(%{rake svn:checkout DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      File.new("error.log").readlines(nil)[0].should match(/.*destination.*already.*exists.* /)
    end
    after (:each) do    
      FileUtils.rm_rf @drive_dir
    end
  end
end
  
describe "ror", "#existing project" do
  before (:all) do
      @drive_dir = "/Users/muthu/project/svn_unittest/"
      @project_uri = "http://indiaserver.no-ip.info/repo/dummy/trunk"
      @project_name = "dummy/"    
      @build_dir = "/Users/muthu/project/builds/1/"
      @commit_report = "commit.report"
  end
  context "update on an empty drive" do   
    before (:each) do
      FileUtils.mkdir_p @drive_dir
    end
    it "should fail" do
      system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} 2>error.log 1>out.log})
      $?.success?.should == false 
    end                           
    it "show report 'No such file or directory ' error" do
      system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} 2>error.log 1>out.log})
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
        system %{svn checkout #{@project_uri} #{@project_name}}
      end
    end
    context "with same project in drive" do
      it "should be successfull" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report}})  
        $?.success?.should == true
      end
      it "should return commit id" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/[^|]+|[^|]+|[^|]+|[^|]+[^|]+.*/)
      end
      it "should return commit by" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/[^|]+|[^|]+|[^|]+|[^|]+[^|]+.*/)
      end
      it "should return commit date" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/[^|]+|[^|]+|[^|]+|[^|]+[^|]+.*/)
      end
      it "should return commit message" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*Changed paths:.*/)
      end
      it "should return changed files list" do
        system(%{rake svn:update DRIVE_DIR=#{@drive_dir} PROJECT_NAME=#{@project_name} BUILD_DIR=#{@build_dir} COMMIT_REPORT=#{@commit_report} 2>error.log 1>out.log})  
        File.new(@build_dir+@commit_report).readlines(nil)[0].should match(/.*\n\n\w+.*\n-+.*/)
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
