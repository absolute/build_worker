require "spec_helper"

describe "BuildJob", "with a project in the build queue" do
  context "and amazon ec2 instance available" do
    it "should mount the project's EBS volume to the ec2 instance"
    it "should start the build in the ec2 instance" 
    it "should update the project status to building"
  end
    context "and amazon ec2 instance NOT available" do
      it "should stop furthur processing the queue"
      it "should NOT update the project status"
    end
end
describe "BuildJob" do
  context "with empty build queue" do
    it "should quit"                   
  end
  context "with NO projects in 'committed' status" do
    it "should quit"
  end
end
                          