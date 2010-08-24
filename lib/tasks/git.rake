require "fileutils"                                       

namespace "git" do

desc "build RubyOnRails project"
task "checkout" do                   
    Dir.chdir(%{#{ENV["PROJECT_FOLDER"]}}) do 
      sh %{git clone #{ENV['PROJECT_URI']} source}
    end            
end
directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"
task "update" => ["#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
    source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
    build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
    Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
        sh %{git pull origin master}
        sh %{git show --pretty=fuller --name-status > ../#{ENV['BUILD_ID']}/commit.report}
    end                                                        
    commit_details = Hash.new()
    out = File.new(build_folder+"commit.report").readlines(nil)[0]
    commit_details["commit_id"] = out.scan(/commit\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_by"] = out.scan(/Commit:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_on"] = out.scan(/CommitDate:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_message"] = out.scan(/\n\n(.+)\n\n/).flatten[0].strip
    commit_details["changed_files"] = out.scan(/([MAD]\t.*)/).flatten
    File.open(build_folder+"commit.report", 'w' ) do |out|
        YAML.dump(commit_details, out) 
    end
end               

end
