require 'erb'
require "spec_helper"

describe "ror", "#build" do
  context "with a new project" do     
    it "should load the environment"
    it "should checkout the repository"
    it "should setup the database"
    it "should run the user test"
  end                           
  context "with and existing project" do
    it "should load the environment"
    it "should update from the repository"
    it "should setup the database"
    it "should run the user test"   
    end
end                                   

describe "ror", "#environment" do
  context "with a valid environment file" do
    before :each do                    
      @drive_dir = "/Users/muthu/project/drive/" 
      @project_name = "build worker" 
      FileUtils.mkdir_p @drive_dir+"build_worker"    
      @env_file = @drive_dir+"build_worker/environment.yml"; 
      env = {"drive_dir" => "/Users/muthu/project/drive/", "source" => "source/", "builds" => "builds/", "commit_report" => "commit.report"}
      File.open( @env_file, 'w' ) do |out|
          YAML.dump(env, out) 
      end
    end
    it "should load it successfully" do        
        x = 50
        template = ERB.new <<-EOF
          The value of x is: <%= x %>
        EOF
        puts template.result(binding)
      system(%{rake ror:environment DRIVE_DIR="#{@drive_dir}" PROJECT_NAME="#{@project_name}" > out.log})    
      $?.success?.should == true
    end   
    it "should have drive directory" do
      File.new(@env_file).readlines(nil)[0].should match(/.*drive_dir:.*/)
    end                      
    it "should have source folder" do
      File.new(@env_file).readlines(nil)[0].should match(/.*source:.*/)
    end
    it "should have builds folder" do
      File.new(@env_file).readlines(nil)[0].should match(/.*builds:.*/)
    end
    it "should have commit report" do
      File.new(@env_file).readlines(nil)[0].should match(/.*commit_report:.*/)
    end
    after (:each) do
      FileUtils.rm_rf @drive_dir
    end
  end
  context "with missing environment file" do
    before :each do                    
      @drive_dir = "/Users/muthu/project/drive/" 
      @project_name = "build worker" 
      FileUtils.mkdir_p @drive_dir+"build_worker"     
    end
    it "should fail" do
      system(%{rake ror:environment DRIVE_DIR="#{@drive_dir}" PROJECT_NAME="#{@project_name}" > out.log})    
      $?.success?.should == false
    end
    after (:each) do
      FileUtils.rm_rf @drive_dir
    end
  end  
  context "with some properties missing from environment file" do
    before :each do                    
      @drive_dir = "/Users/muthu/project/drive/" 
      @project_name = "build worker" 
      FileUtils.mkdir_p @drive_dir+"build_worker"    
      @env_file = @drive_dir+"build_worker/environment.yml"; 
      env = {"drive_dir" => "/Users/muthu/project/drive/", "commit_report" => "commit.report"}
      File.open( @env_file, 'w' ) do |out|
          YAML.dump(env, out) 
      end     
    end
    it "should fail" do
      system(%{rake ror:environment DRIVE_DIR="#{@drive_dir}" PROJECT_NAME="#{@project_name}" > out.log})    
      $?.success?.should == false
    end
    after (:each) do
      FileUtils.rm_rf @drive_dir
    end
  end
end
    
    