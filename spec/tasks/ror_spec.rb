require 'erb'
require "spec_helper"
require "rake"   
require "tasks/tasks_helper"     


describe :ror, "#config" do
  include TasksHelper
  context "with valid environment file and build id" do
    before :each do    
      mark_env
      @project_folder = "/Users/muthu/project/drive/build_worker/"    
      @env_file = @project_folder+"environment.yml"                          
      @build_id = "123.12"
      @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake test", :ebs_vol=>@drive_dir}
      @env = {"project" => @project, "project_folder" => "#{@project_folder}"}
      YAML.should_receive(:load_file).with(@env_file).and_return(@env)
      ENV['ENV_FILE'] = @env_file
      ENV['BUILD_ID'] = @build_id
      @rake = Rake::Application.new
      Rake.application = @rake
      Rake.application.rake_require "lib/tasks/ror"
    end
    it "should checkout the repository" do 
      Rake::Task.define_task("git:checkout").should_receive(:invoke)  
      Rake::Task.define_task("ror:database_setup")
      Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).any_number_of_times
      @rake["ror:config"].invoke
    end
    it "should setup the database" do
      Rake::Task.define_task("git:checkout")    
      Rake::Task.define_task("ror:database_setup").should_receive(:invoke).with("for_builds/", "#{@project_folder}source/config/")
      Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).any_number_of_times
      @rake["ror:config"].invoke
    end
    it "should run the user command" do
      Rake::Task.define_task("git:checkout")    
      Rake::Task.define_task("ror:database_setup")
      Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).with(@project[:command])
      @rake["ror:config"].invoke
    end
    after :each do  
      reset_env
    end
  end   
  
  context "with invalid environment file" do
    before :each do      
       mark_env
       YAML.should_receive(:load_file).and_raise(ConfigError)
       @rake = Rake::Application.new
       Rake.application = @rake
       Rake.application.rake_require "lib/tasks/ror"    
       ENV['BUILD_ID'] = "123.12"
    end
    it "should raise config error" do          
      lambda {
        @rake["ror:config"].invoke
      }.should raise_error(ConfigError)
    end
    after :each do    
      reset_env
    end
  end   
  
  context "with mandatory properties missing in environment" do
    before :each do     
      mark_env
      @rake = Rake::Application.new
      Rake.application = @rake
      Rake.application.rake_require "lib/tasks/ror"
      YAML.should_receive(:load_file).and_return({})     
      ENV['BUILD_ID'] = "123.12"
    end
    it "should raise config error" do
      lambda {
        @rake["ror:config"].invoke
      }.should raise_error(ConfigError, /PROJECT_SCM.+PROJECT_COMMAND/)
    end
    after :each do   
      reset_env
    end
  end
  context "with no build_id" do
    before :each do
      @rake = Rake::Application.new
      Rake.application = @rake
      Rake.application.rake_require "lib/tasks/ror"
    end
    it "should raise config error" do
      lambda {
        @rake["ror:config"].invoke
      }.should raise_error(ConfigError, /BUILD_ID/)
    end
  end                                            
end                                 
            
describe :ror, "#create_build" do    
  include TasksHelper
  before :each do    
    mark_env
    @project_folder = "/Users/muthu/project/drive/build_worker/"    
    @env_file = @project_folder+"environment.yml"                          
    @build_id = "123.12"
    @project = {:id=>1, :name=>"build_worker", :uri=>"uri", :scm=>"git", :branch=>"master", :command=>"rake test", :ebs_vol=>@drive_dir}
    @env = {"project" => @project, "project_folder" => "#{@project_folder}"}
    YAML.should_receive(:load_file).with(@env_file).and_return(@env)
    ENV['ENV_FILE'] = @env_file
    ENV['BUILD_ID'] = @build_id
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/ror"
  end  
  context "without commit" do
    it "should get latest from repository" do
      Rake::Task.define_task("git:update").should_receive(:invoke)  
      Rake::Task.define_task("ror:database_setup").should_receive(:invoke).any_number_of_times
      Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).any_number_of_times
      @rake["ror:create_build"].invoke
    end 
    it "should setup database" do
      Rake::Task.define_task("git:update").should_receive(:invoke).any_number_of_times
      Rake::Task.define_task("ror:database_setup").should_receive(:invoke).with("for_builds/", "#{@project_folder}source/config/")
      Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).any_number_of_times
      @rake["ror:create_build"].invoke
    end
    it "should run user command" do
        Rake::Task.define_task("git:update").should_receive(:invoke).any_number_of_times
        Rake::Task.define_task("ror:database_setup").should_receive(:invoke).any_number_of_times
        Rake::Task.define_task("ror:run_user_command").should_receive(:invoke).with("#{@project[:command]}")
        @rake["ror:create_build"].invoke
      end
  end                    
  context "with commit" do
    it "should get changes for the commit"
    it "should setup database"
    it "should run user command"
  end
  after :each do
    reset_env
  end
end

describe :ror, "#database_setup" do
  include TasksHelper
  before :each do   
    mark_env
    ENV['PROJECT_FOLDER'] = "/Users/muthu/project/drive/build_worker/"
    @source = "for_builds/"
    @target = "#{ENV['PROJECT_FOLDER']}source/config/"
    FileUtils.mkdir_p @target
  end
  context "with database file in the project" do
    it "should create a link to the worker database file" do
      File.open("#{@target}database.yml", 'w') do |out| 
        out.write("database config goes here")
      end
      File.exists?("#{@target}/database.yml").should == true
      system (%{rake --trace ror:database_setup["#{@source}","#{@target}"]})
      File.symlink?("#{@target}/database.yml").should == true
    end
  end
  context "without database file in the project" do
    it "should NOT create a link to the worker database file" do
      File.exists?("#{@target}/database.yml").should == false
      File.symlink?("#{@target}/database.yml").should == false
      system (%{rake --trace ror:database_setup["#{@source}","#{@target}"]})
      File.symlink?("#{@target}/database.yml").should == false
    end
  end                
  after :each do
    FileUtils.rm_rf ENV['PROJECT_FOLDER']
    reset_env 
  end
end

describe :ror, "#run_user_command" do  
  include TasksHelper
  before :each do 
    mark_env
    ENV['PROJECT_FOLDER'] = "/Users/muthu/project/drive/build_worker/"
    ENV['BUILD_ID'] = "123.123"
    FileUtils.mkdir_p ENV['PROJECT_FOLDER']+ENV['BUILD_ID']
  end
  context "with a user command" do
    it "should finish with 'Build Completed' status" do
      ENV['PROJECT_COMMAND'] = "pwd"                                  
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"]})
      IO.read(ENV['PROJECT_FOLDER']+ENV['BUILD_ID']+"/build.status").should match(/Finished '#{ENV['PROJECT_COMMAND']}'/)                         
    end
    it "should run the command" do             
      ENV['PROJECT_COMMAND'] = "pwd"                                  
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"]})
      IO.read(ENV['PROJECT_FOLDER']+ENV['BUILD_ID']+"/build.log").should match(/drive\/build_worker/)                         
    end
  end
  context "with no user command" do
    it "should fail" do                   
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"]})
      $?.should_not be_success
    end   
    it "should report the error" do
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"] > out.log 2>&1})
      IO.read("out.log").should match(/ERROR: user command missing/)                         
    end
  end
  context "with invalid user command" do
    it "should fail" do
      ENV['PROJECT_COMMAND'] = "pwda"                                  
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"]})
      $?.should_not be_success
    end          
    it "should report the error" do
      ENV['PROJECT_COMMAND'] = "pwda"                                  
      system (%{rake --trace ror:run_user_command["#{ENV['PROJECT_COMMAND']}"] > out.log 2>&1})
      IO.read("out.log").should match(/ERROR: user command failed/)                         
    end
  end       
  after :each do
    FileUtils.rm_rf ENV['PROJECT_FOLDER']
    reset_env                          
  end
end

 

    