require "spec_helper"
require "rake" 
require "tasks/build_config"

describe "svn" do  
  before (:each) do          
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/svn"
    @cfg = BuildConfig.new({:drive=>"drive", 
      :project_name =>"dummy", 
      :build_id     =>"123.12", 
      :project_uri  =>"http://indiaserver.no-ip.info/repo/dummy/trunk", 
      :auth_type    =>"password", 
      :username     =>"muthu", 
      :password     =>"muthu" })
  end   
  context "#checkout", "with an empty drive" do   
    context "with valid password" do
      before (:each) do              
        FileUtils.mkdir_p @cfg.build_folder
      end                      
      it "should end successfully" do              
        Rake::Task['svn:checkout'].invoke(@cfg)
        $?.success?.should == true
      end
      it "should checkout from repository" do            
        File.exists?(@cfg.source_folder).should == false    
        Rake::Task['svn:checkout'].invoke(@cfg)
        Dir.entries(@cfg.source_folder).select {|n| n =~ /^\w/}.should_not be_empty    
      end                             
    end                     
    context "with INVALID password" do
      before (:each) do              
        @cfg = BuildConfig.new({:drive=>"drive", 
          :project_name =>"dummy", 
          :build_id     =>"123.12", 
          :project_uri  =>"http://indiaserver.no-ip.info/repo/dummy/trunk", 
          :auth_type    =>"password", 
          :username     =>"muthu", 
          :password     =>"wrong" })
        FileUtils.mkdir_p @cfg.build_folder  
      end                      
      it "should raise exception" do             
        lambda {
          Rake::Task['svn:checkout'].invoke(@cfg)    
        }.should raise_error(Exception)
      end
      it "should log 'authorization failed' error" do
        begin
          Rake::Task['svn:checkout'].invoke(@cfg)    
        rescue
        end                                     
        IO.read(@cfg.build_log).should match(/authorization failed/)
      end
    end
  end                                 
  context "#checkout", "with a NON-empty drive" do             
    before (:each) do
      FileUtils.mkdir_p "#{@cfg.source_folder}/tmp"
    end
    it "should fail" do                                                             
      pending ("svn doesn't report error if trying to checkout for second time")
      Rake::Task['svn:checkout'].invoke(@cfg)
      $?.success?.should == false      
    end    
    it "should report 'destination already exists' error" do
      pending ("svn doesn't report error if trying to checkout for second time")
      Rake::Task['svn:checkout'].invoke(@cfg)
      File.new("error.log").readlines(nil)[0].should match(/.*destination.*already.*exists.* /)
    end
  end 
  context "#update", "with an empty drive" do   
    it "should raise 'No such file or directory' exception" do      
      lambda {
        Rake::Task['svn:update'].invoke(@cfg)
        }.should raise_error(Exception, /No such file or directory/)
    end                           
  end                                                               
  context "#update", "with same project in drive" do
    before (:each) do    
      FileUtils.mkdir_p @cfg.build_folder
      Dir.chdir(@cfg.project_folder) do 
        system %{svn checkout #{@cfg.project_uri} source}
      end                                                          
    end
    it "should be successfull" do      
      Rake::Task['svn:update'].invoke(@cfg)
      $?.success?.should == true
    end
    it "should return commit id" do
      Rake::Task['svn:update'].invoke(@cfg)
      File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_id:\s*/)   
    end
    it "should return commit by" do
      Rake::Task['svn:update'].invoke(@cfg)
      File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_by:\s*/)   
    end
    it "should return commit on" do
      Rake::Task['svn:update'].invoke(@cfg)
      File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_on:\s*/)   
    end
    it "should return commit message" do
      Rake::Task['svn:update'].invoke(@cfg)
      File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*commit_message:\s*/)   
    end
    it "should return changed files" do
      Rake::Task['svn:update'].invoke(@cfg)
      File.new(@cfg.commit_report).readlines(nil)[0].should match(/.*changed_files:\s*/)   
    end
  end
  context "#update", "with different project in drive" do
    it "should return error details"
  end        
  after (:each) do    
    FileUtils.rm_rf @cfg.project_folder
  end
end
