require "spec_helper"
require "lib/amazon_cloud/ec2_manager"

describe "EC2Manager" do
  context "with no build servers running" do
    before :each do
      @ec2Manager = EC2Manager.new        
      @project = {:project_id => 1, :committed_on => 2.minutes.ago}
    end
    it "should start a server" do        
      @ec2Manager.running_count.should equal(0) 
      lambda {
        server = @ec2Manager.get_server(@project)      
      }.call
      @ec2Manager.running_count.should equal(1)      
    end   
    it "should return server details" do
      server = @ec2Manager.get_server(@project)
      server.should have_key(:instance_id)
    end
  end                                               
  
  context "with only build server busy" do
    context "and project have been commited long time ago (>5 minutes)" do
    before :each do
      @ec2Manager = EC2Manager.new
      @ec2Manager.get_server({:project_id => 1, :committed_on => 6.minutes.ago})
      @project = {:project_id => 2, :committed_on => 6.minutes.ago}
    end
    it "should start a second server" do
      @ec2Manager.running_count.should equal(1)
      @ec2Manager.get_server(@project)
      @ec2Manager.running_count.should equal(2)
    end
    it "should return server details" do                                  
      server = @ec2Manager.get_server(@project)
      server.should have_key(:instance_id)     
    end
    end
   
    context "and project have been committed recently (<5 minutes)" do
      before :each do
        @ec2Manager = EC2Manager.new
        @ec2Manager.get_server({:project_id => 1, :committed_on => 6.minutes.ago})
        @project = {:project_id => 2, :committed_on => 2.minutes.ago}
      end
      it "should NOT start a second server" do
        @ec2Manager.running_count.should equal(1)
        catch(:try_after_5_mins) do
          @ec2Manager.get_server(@project)
        end
        @ec2Manager.running_count.should equal(1)
      end
      it "should say 'try after 5 mins'" do   
        lambda {
          @ec2Manager.get_server(@project)
        }.should throw_symbol(:try_after_5_mins)
      end
    end
  end
                                                 
  context "with one server idle for more than 1 hour" do
    it "should stop the idle server"
  end
  context "with one server idle for less than 1 hour" do
    it   "should NOT stop the idle server"
  end
end