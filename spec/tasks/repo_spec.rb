require "spec_helper"

describe "repo", "#git" do                     
  before :all do
    @repo_type = "git"
  end
  context "with new repository" do
    it "should run git checkout command" do
      system(%{rake repo:checkout --trace REPO_TYPE=#{@repo_type} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke git:checkout.*/) 
    end
  end
  context "with existing repository" do
    it "should run git update command" do
      system(%{rake repo:update --trace REPO_TYPE=#{@repo_type} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke git:update.*/) 
    end
  end
end
describe "repo", "#svn" do
  before :all do
    @repo_type = "svn"
  end
  context "with new repository" do
    it "should run svn checkout command" do
      system(%{rake repo:checkout --trace REPO_TYPE=#{@repo_type} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke svn:checkout.*/) 
    end
  end
  context "with existing repository" do
    it "should run svn update command" do
      system(%{rake repo:update --trace REPO_TYPE=#{@repo_type} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke svn:update.*/) 
    end
  end
end