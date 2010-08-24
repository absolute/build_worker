require "spec_helper"

describe "git", "#new project" do  
  before (:all) do
      @project_folder = "drive/build_worker/"
      @build_id = "123.123"
      @project_uri = "git://github.com/absolute/build_worker.git"
  end
  context "checkout on an empty drive" do     
    before (:each) do    
      FileUtils.mkdir_p @project_folder+@build_id
    end
    it "should end successfully" do  
      system(%{rake git:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      $?.success?.should == true
    end
    it "should checkout from repository" do     
      File.exists?("#{@project_folder}source").should == false    
      system(%{rake git:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      Dir.entries("#{@project_folder}source").select {|n| n =~ /^\w/}.should_not be_empty    
    end                                                  
    after (:each) do
      FileUtils.rm_rf @project_folder
    end
  end                                 
  context "checkout on a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@project_folder}/source/tmp"
    end
    it "should fail" do                                                             
      system(%{rake git:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      $?.success?.should == false      
    end    
    it "should report 'destination already exists' error" do
      system(%{rake git:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri} 2>error.log 1>out.log})    
      File.new("error.log").readlines(nil)[0].should match(/.*destination.*already.*exists.* /)
    end
    after (:each) do    
      FileUtils.rm_rf @project_folder
    end
  end
end
  
describe "git", "#existing project" do
  before (:all) do
    @project_folder = "drive/build_worker/"
    @build_id = "123.123"
    @project_uri = "git://github.com/absolute/build_worker.git"
  end
  context "update on an empty drive" do   
    before (:each) do
      FileUtils.mkdir_p @project_folder
    end
    it "should fail" do
      system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})
      $?.success?.should == false 
    end                           
    it "show report 'No such file or directory ' error" do
      system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})
      File.new("error.log").readlines(nil)[0].should match(/.*No.such.file.or.directory.*/)
    end  
    after (:each) do
      FileUtils.rm_rf @project_folder
    end
  end  
  context "update on a NON-empty drive" do
    before (:all) do
      FileUtils.mkdir_p @project_folder                      
      Dir.chdir("#{@project_folder}") do 
        system %{git clone #{@project_uri} source}
        Dir.chdir("source") do
          system %{git reset --hard 1d83c209d0233667b2ab50cc82c1a2f008999b16}
        end
      end  
      @commit_report =  @project_folder+@build_id+"/commit.report"
    end
    context "with same project in drive" do
      it "should be successfull" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
        $?.success?.should == true
      end
      it "should return commit id" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
      end
      it "should return commit by" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})  
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)
      end
      it "should return commit on" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})  
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)
      end
      it "should return commit message" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})  
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_message:.*/)
      end
      it "should return changed files" do
        system(%{rake git:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})  
        File.new(@commit_report).readlines(nil)[0].should match(/.*changed_files:.*/)
      end
    end
    context "with an invalid repository" do
      it "should return error details"
    end                       
    after (:all) do
      FileUtils.rm_rf @project_folder
    end
  end        

end  
