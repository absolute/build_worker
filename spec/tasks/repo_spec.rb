require "spec_helper"

describe "repo", "#git" do                     
  before :all do
    @project_scm = "git"     
  end
  context "with new repository" do
    it "should run git checkout command" do
      system(%{rake repo:checkout --trace PROJECT_SCM=#{@project_scm} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke git:checkout.*/) 
    end
  end
  context "with existing repository" do
    it "should run git update command" do
      system(%{rake repo:update --trace PROJECT_SCM=#{@project_scm} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke git:update.*/) 
    end
  end
end
describe "repo", "#svn" do
  before :all do
    @project_scm = "svn"
  end
  context "with new repository" do
    it "should run svn checkout command" do
      system(%{rake repo:checkout --trace PROJECT_SCM=#{@project_scm} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke svn:checkout.*/) 
    end
  end
  context "with existing repository" do
    it "should run svn update command" do
      system(%{rake repo:update --trace PROJECT_SCM=#{@project_scm} > out.log})    
      File.new("out.log").readlines(nil)[0].should match(/.*Invoke svn:update.*/) 
    end
  end
end