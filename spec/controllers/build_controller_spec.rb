require 'spec_helper'

describe BuildController do
                     
context "build with valid project" do
  it "should be successful" do       
    post :create, :project=>{:id=>1}
    @response.should be_success
  end                                                   
  it "should return 'building' status" do
    post :create, :project=>{:id=>1}      
    @response.should have_tag("status", :text => "building")
  end
  it "should return build id" do
    post :create, :project=>{:id=>1}      
    @response.should have_tag("build-id", :text => "1")
  end
  it "should return reports url" do
    post :create, :project=>{:id=>1}      
    @response.should have_tag("reports-url", :text => "http://aws.amazon.com/1/reports")
  end
end                              

context "build with invalid project" do
  it "should return error details"
end
                                 
context "check build status with valid project" do
  it "should return build status" do
    post :status, :project=>{:id=>1}
    @response.should have_tag("status", :text => "building")
  end
end                             

context "check build status with invalid project" do
  it "should return error details"
end                             

context "delete running build" do
  it "should kill the running build"
end                     

context "delete completed build" do
  it "should return error"
end
end
