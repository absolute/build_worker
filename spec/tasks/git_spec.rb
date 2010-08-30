require "spec_helper"
require "rake"
require "tasks/build_config"

describe "git", "#ssh key" do      
  before :each do  
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/git"
    @cfg = BuildConfig.new({:drive=>"drive", 
      :project_name =>"build_worker", 
      :build_id     =>"123.123",
      :worker_folder => Dir.getwd,
      :ssh_folder_to => "ssh"})
    FileUtils.mkdir_p @cfg.ssh_folder_to    
  end
  context "not set in config" do  
    before :each do
      File.open(@cfg.ssh_config_to, "w") do |f|
        f.write("already existing config")
      end
    end
    it "should copy the public key" do
      File.exists?(@cfg.ssh_public_key_to).should == false  
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
      File.exists?(@cfg.ssh_public_key_to).should == true
    end
    it "should copy the private key" do
      File.exists?(@cfg.ssh_private_key_to).should == false
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
      File.exists?(@cfg.ssh_private_key_to).should == true
    end
    it "should update ssh config file" do
      IO.read(@cfg.ssh_config_to).should_not match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
       IO.read(@cfg.ssh_config_to).should match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
    end
  end
  context "already set in config" do
    it "should NOT update ssh config file" do
      File.open(@cfg.ssh_config_to, "w") do |f|
         f.write("IdentityFile ~/.ssh/id_rsa.pureapp\n")
       end
       before_line_count = IO.readlines(@cfg.ssh_config_to).size
       Rake::Task['git:set_ssh_key'].invoke(@cfg)
       IO.readlines(@cfg.ssh_config_to).size.should == before_line_count
     end
  end                                        
   context "with config file missing" do
    it "should copy the public key" do
      File.exists?(@cfg.ssh_public_key_to).should == false
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
      File.exists?(@cfg.ssh_public_key_to).should == true
    end
    it "should copy the private key" do
      File.exists?(@cfg.ssh_private_key_to).should == false
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
      File.exists?(@cfg.ssh_private_key_to).should == true
    end
    it "should create ssh config file" do
      File.exists?(@cfg.ssh_config_to).should == false
      Rake::Task['git:set_ssh_key'].invoke(@cfg)
      IO.read(@cfg.ssh_config_to).should match(/IdentityFile ~\/\.ssh\/id_rsa\.pureapp/)
    end
  end
  after :each do
    FileUtils.rm_rf @cfg.ssh_folder_to
  end
end

describe "git", "#checkout" do  
  before (:each) do   
    @cfg = BuildConfig.new({:drive=>"drive", 
      :project_name =>"build_worker", 
      :build_id     =>"123.123",     
      :worker_folder => Dir.getwd,
      :project_uri  =>"git://github.com/absolute/build_worker.git"})
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/git"
    FileUtils.mkdir_p @cfg.build_folder
  end                 
  context "with an empty drive" do     
    it "should have prerequisites for set ssh key" do                     
      Rake::Task["git:checkout"].prerequisites.should include("set_ssh_key")
    end
    it "should end successfully" do    
      Rake::Task["git:checkout"].clear_prerequisites
      Rake::Task['git:checkout'].invoke(@cfg)
      $?.success?.should == true
    end
    it "should checkout from repository" do     
      Rake::Task["git:checkout"].clear_prerequisites
      File.exists?(@cfg.source_folder).should == false    
      Rake::Task['git:checkout'].invoke(@cfg)
      Dir.entries(@cfg.source_folder).select {|n| n =~ /^\w/}.should_not be_empty    
    end                                                  
  end                                 
  context "with a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@cfg.source_folder}/tmp"
      Rake::Task["git:checkout"].clear_prerequisites
    end
    it "should raise exception" do                                                             
      lambda {
        Rake::Task['git:checkout'].invoke(@cfg)
      }.should raise_error(Exception)
    end    
    it "should report 'destination already exists' error" do
      begin 
        Rake::Task['git:checkout'].invoke(@cfg)
      rescue
      end
      IO.read(@cfg.build_log).should match(/.*destination.*already.*exists.* /)
    end
  end  
  after (:each) do
    FileUtils.rm_rf @cfg.project_folder   
  end
end
  
describe "git", "#update" do
  before (:all) do    
    @cfg = BuildConfig.new({:drive=>"drive", 
      :project_name =>"build_worker", 
      :build_id     =>"123.123",
      :worker_folder => Dir.getwd,
      :project_uri  =>"git://github.com/absolute/build_worker.git"})
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/git"
    FileUtils.mkdir_p @cfg.build_folder
  end
  context "with an empty drive" do   
    it "should have prerequisites for set ssh key" do                     
      Rake::Task["git:update"].prerequisites.should include("set_ssh_key")
    end    
    it "should raise 'No such file or directory' exception" do
      Rake::Task["git:update"].clear_prerequisites 
      lambda {
        Rake::Task['git:update'].invoke(@cfg)
      }.should raise_error(Exception, /.*No.such.file.or.directory.*/)
    end                           
  end  
  context "with a NON-empty drive" do
    before (:all) do
      Dir.chdir(@cfg.project_folder) do 
        system %{git clone #{@cfg.project_uri} #{@cfg.source_folder}}
        Dir.chdir(@cfg.source_folder) do
          system %{git reset --hard 1d83c209d0233667b2ab50cc82c1a2f008999b16}
        end
      end   
      Rake::Task["git:update"].clear_prerequisites 
    end
    context "with same project in drive" do
      it "should be successfull" do
        Rake::Task['git:update'].invoke(@cfg)
        $?.should be_success
      end
      it "should return commit id" do
        Rake::Task['git:update'].invoke(@cfg)
        File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
      end
      it "should return commit by" do
        Rake::Task['git:update'].invoke(@cfg)
        File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)
      end
      it "should return commit on" do
        Rake::Task['git:update'].invoke(@cfg)
        File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)
      end
      it "should return commit message" do
        Rake::Task['git:update'].invoke(@cfg)
        File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_message:.*/)
      end
      it "should return changed files" do
        Rake::Task['git:update'].invoke(@cfg)
        File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*changed_files:.*/)
      end
    end
    context "with an invalid repository" do
      it "should return error details"
    end                       
  end        
  after (:all) do
    FileUtils.rm_rf @cfg.project_folder
  end

end  
