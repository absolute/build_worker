require "spec_helper"

describe "EC2Manager" do
  context "with no build servers running" do
    it "should start a server"   
    it "should return server details"
  end
  context "with only build server busy" do
    context "and project have been commited long time ago (>5 minutes)" do
    it "should start a second server"
    it "should return server details"                                  
    end
    context "and project have been committed recently (<5 minutes)" do
      it "should NOT start a second server"
      it "should say 'no servers available - try after 5 mins'"
    end
  end                                               
  context "with one server idle for more than 1 hour" do
    it "should stop the idle server"
  end
  context "with one server idle for less than 1 hour" do
    it   "should NOT stop the idle server"
  end
end