require "spec_helper"
require "rake"
require "tasks/tasks_helper"

describe "git", "#ssh key" do      
  before :each do
    @ssh_folder = "ssh/"
    FileUtils.mkdir_p @ssh_folder    
  end
  context "not set in config" do  
    before :each do
      File.open(@ssh_folder+"config", "w") do |f|
        f.write("already existing config")
      end
    end
    it "should copy the public key" do
      File.exists?(@ssh_folder+"id_rsa.pureapp.pub").should == false
      system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
      File.exists?(@ssh_folder+"id_rsa.pureapp.pub").should == true
    end
    it "should copy the private key" do
      File.exists?(@ssh_folder+"id_rsa.pureapp").should == false
      system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
      File.exists?(@ssh_folder+"id_rsa.pureapp").should == true
    end
    it "should update ssh config file" do
      IO.read("#{@ssh_folder}config").should_not match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
       system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
       IO.read("#{@ssh_folder}config").should match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
    end
  end
  context "already set in config" do
    it "should NOT update ssh config file" do
      File.open(@ssh_folder+"config", "w") do |f|
         f.write("IdentityFile ~/.ssh/id_rsa.pureapp\n")
       end
       before_line_count = IO.readlines("#{@ssh_folder}config").size
       system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})   
       IO.readlines("#{@ssh_folder}config").size.should == before_line_count
     end
  end                                        
   context "with config file missing" do
    it "should copy the public key" do
      File.exists?(@ssh_folder+"id_rsa.pureapp.pub").should == false
      system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
      File.exists?(@ssh_folder+"id_rsa.pureapp.pub").should == true
    end
    it "should copy the private key" do
      File.exists?(@ssh_folder+"id_rsa.pureapp").should == false
      system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
      File.exists?(@ssh_folder+"id_rsa.pureapp").should == true
    end
    it "should create ssh config file" do
      File.exists?(@ssh_folder+"config").should == false
      system(%{rake git:set_ssh_key SSH_FOLDER="#{@ssh_folder}"})
      IO.read("#{@ssh_folder}config").should match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
    end
  end
  after :each do
    FileUtils.rm_rf @ssh_folder
  end
end

describe "git", "#checkout" do  
  include TasksHelper
  before (:each) do   
      mark_env
      @project_folder = "drive/build_worker/"
      @build_id = "123.123"
      @project_uri = "git://github.com/absolute/build_worker.git"  
      @rake = Rake::Application.new
      Rake.application = @rake
      Rake.application.rake_require "lib/tasks/git"
      ENV['PROJECT_FOLDER']=@project_folder 
      ENV['BUILD_ID']=@build_id 
      ENV['PROJECT_URI']=@project_uri
      FileUtils.mkdir_p @project_folder+@build_id
  end                 
  context "with an empty drive" do     
    it "should have prerequisites for set ssh key" do                     
      Rake::Task["git:checkout"].prerequisites.should include("set_ssh_key")
    end
    it "should end successfully" do    
      Rake::Task["git:checkout"].clear_prerequisites
      Rake::Task['git:checkout'].invoke
      $?.success?.should == true
    end
    it "should checkout from repository" do     
      Rake::Task["git:checkout"].clear_prerequisites
      File.exists?("#{@project_folder}source").should == false    
      Rake::Task['git:checkout'].invoke
      Dir.entries("#{@project_folder}source").select {|n| n =~ /^\w/}.should_not be_empty    
    end                                                  
  end                                 
  context "with a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@project_folder}/source/tmp"
      Rake::Task["git:checkout"].clear_prerequisites
    end
    it "should raise exception" do                                                             
      lambda {
        Rake::Task['git:checkout'].invoke
      }.should raise_error(Exception)
    end    
    it "should report 'destination already exists' error" do
      begin 
        Rake::Task['git:checkout'].invoke
      rescue
      end
      IO.read(@project_folder+@build_id+"/build.log").should match(/.*destination.*already.*exists.* /)
    end
  end  
  after (:each) do
    FileUtils.rm_rf @project_folder   
  end
end
  
describe "git", "#update" do
  before (:all) do
    @project_folder = "drive/build_worker/"
    @build_id = "123.123"
    @project_uri = "git://github.com/absolute/build_worker.git"  
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/git"
    ENV['PROJECT_FOLDER']=@project_folder 
    ENV['BUILD_ID']=@build_id 
    ENV['PROJECT_URI']=@project_uri
    FileUtils.mkdir_p @project_folder+@build_id
  end
  context "with an empty drive" do   
    it "should have prerequisites for set ssh key" do                     
      Rake::Task["git:update"].prerequisites.should include("set_ssh_key")
    end    
    it "should raise 'No such file or directory' exception" do
      Rake::Task["git:update"].clear_prerequisites 
      lambda {
        Rake::Task['git:update'].invoke
      }.should raise_error(Exception, /.*No.such.file.or.directory.*/)
    end                           
  end  
  context "with a NON-empty drive" do
    before (:all) do
      Dir.chdir("#{@project_folder}") do 
        system %{git clone #{@project_uri} source}
        Dir.chdir("source") do
          system %{git reset --hard 1d83c209d0233667b2ab50cc82c1a2f008999b16}
        end
      end   
      Rake::Task["git:update"].clear_prerequisites 
      @commit_report =  @project_folder+@build_id+"/commit.report"
    end
    context "with same project in drive" do
      it "should be successfull" do
        Rake::Task['git:update'].invoke
      end
      it "should return commit id" do
        Rake::Task['git:update'].invoke
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
      end
      it "should return commit by" do
        Rake::Task['git:update'].invoke
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)
      end
      it "should return commit on" do
        Rake::Task['git:update'].invoke
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)
      end
      it "should return commit message" do
        Rake::Task['git:update'].invoke
        File.new(@commit_report).readlines(nil)[0].should match(/.*commit_message:.*/)
      end
      it "should return changed files" do
        Rake::Task['git:update'].invoke
        File.new(@commit_report).readlines(nil)[0].should match(/.*changed_files:.*/)
      end
    end
    context "with an invalid repository" do
      it "should return error details"
    end                       
  end        
  after (:all) do
    FileUtils.rm_rf @project_folder
  end

end  
