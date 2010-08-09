require 'spec_helper'

describe BuildController do
                     
context "new build with valid project details" do
  it "should create a build" do       
    post :create, :project=>{:id=>1}
    controller.should be_an_instance_of(BuildController)
  end                                                   
  it "should return build details"
end                              

context "new build with invalid project details" do
  it "should return error details"
end
                                 
context "check build status" do
  it "should return build status"
end                             

context "delete running build" do
  it "should kill the running build"
end                     

context "delete completed build" do
  it "should return error"
end
end
