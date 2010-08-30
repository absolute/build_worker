require "spec_helper"
require "rake"

describe "svn" do  
  before (:all) do
    @project_folder = "drive/dummy/"
    @build_id = "123.123"
    @project_uri = "http://indiaserver.no-ip.info/repo/dummy/trunk"
  end   
  context "#auth", "with a valid password" do
    it "should authenticate successfully"
  end            
  context "#auth", "with invalid password" do
    it "should fail with proper error"
  end
  context "#auth", "with wrong auth type" do
    it "should fail with proper error"
  end
  context "#checkout", "with an empty drive" do   
    context "with valid password" do
      before (:each) do              
        ENV['AUTH_TYPE']="password"
        ENV['USERNAME']="muthu"
        ENV['PASSWORD']="muthu"        
        ENV['PROJECT_FOLDER']=@project_folder
        ENV['BUILD_ID']=@build_id
        ENV['PROJECT_URI']=@project_uri
        @rake = Rake::Application.new
        Rake.application = @rake
        Rake.application.rake_require "lib/tasks/svn"
        FileUtils.mkdir_p @project_folder  
      end                      
      it "should end successfully" do  
        Rake::Task['svn:checkout'].invoke
        # system(%{rake svn:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri}})    
        $?.success?.should == true
      end
      it "should checkout from repository" do            
        File.exists?("#{@project_folder}source").should == false    
        system(%{rake svn:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri}})    
        Dir.entries("#{@project_folder}source").select {|n| n =~ /^\w/}.should_not be_empty    
      end                             
    end                     
    context "with INVALID password" do
      before (:each) do              
        ENV['AUTH_TYPE']="password"
        ENV['USERNAME']="muthu"
        ENV['PASSWORD']="muthu2"
        FileUtils.mkdir_p @project_folder  
      end                      
      it "should fail" do  
        system(%{rake svn:checkout PROJECT_FOLDER = #{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri}})    
        $?.success?.should == false
      end
    end
  end                                 
  context "#checkout", "with a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@project_folder}/source/tmp"
    end
    it "should fail" do                                                             
      pending ("svn doesn't report error if trying to checkout for second time")
      system(%{rake svn:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri}})    
      $?.success?.should == false      
    end    
    it "should report 'destination already exists' error" do
      pending ("svn doesn't report error if trying to checkout for second time")
      system(%{rake svn:checkout PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} PROJECT_URI=#{@project_uri}})    
      File.new("error.log").readlines(nil)[0].should match(/.*destination.*already.*exists.* /)
    end
  end 
  context "#update", "with an empty drive" do   
    it "should fail" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})
      $?.success?.should == false 
    end                           
    it "show report 'No such file or directory ' error" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id} 2>error.log 1>out.log})
      File.new("error.log").readlines(nil)[0].should match(/.*No.such.file.or.directory.*/)
    end  
  end  
  context "#update", "with same project in drive" do
    before (:each) do    
      ENV['AUTH_TYPE']="password"
      ENV['USERNAME']="muthu"
      ENV['PASSWORD']="muthu"        
      FileUtils.mkdir_p @project_folder
      Dir.chdir("#{@project_folder}") do 
        system %{svn checkout #{@project_uri} source}
      end                                           
      @commit_report =  @project_folder+@build_id+"/commit.report"
    end
    it "should be successfull" do      
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      $?.success?.should == true
    end
    it "should return commit id" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      File.new(@commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
    end
    it "should return commit by" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      File.new(@commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)   
    end
    it "should return commit on" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      File.new(@commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)   
    end
    it "should return commit message" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      File.new(@commit_report).readlines(nil)[0].should match(/.*commit_message:\s*/)   
    end
    it "should return changed files" do
      system(%{rake svn:update PROJECT_FOLDER=#{@project_folder} BUILD_ID=#{@build_id}})  
      File.new(@commit_report).readlines(nil)[0].should match(/.*changed_files:\s*/)   
    end
  end
  context "#update", "with different project in drive" do
    it "should return error details"
  end        
  after (:each) do    
    FileUtils.rm_rf @project_folder
  end
end
