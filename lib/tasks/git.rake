require "fileutils"                                       

namespace "git" do

desc "build RubyOnRails project"
task "checkout" do
    Dir.chdir(%{#{ENV["DRIVE_DIR"]}}) do 
      sh %{git clone #{ENV['PROJECT_URI']} #{ENV['PROJECT_NAME']}}
    end            
end
directory "#{ENV['BUILD_DIR']}"
task "update" => ["#{ENV['BUILD_DIR']}"] do     
    Dir.chdir(%{#{ENV['DRIVE_DIR']}#{ENV['PROJECT_NAME']}}) do 
        sh %{git pull origin master}
        sh %{git show --pretty=fuller --name-status > #{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}}
    end                                                        
    commit_details = Hash.new()
    out = File.new("#{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}").readlines(nil)[0]
    commit_details["commit_id"] = out.scan(/commit\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_by"] = out.scan(/Commit:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_on"] = out.scan(/CommitDate:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_message"] = out.scan(/\n\n(.+)\n\n/).flatten[0].strip
    commit_details["changed_files"] = out.scan(/([MAD]\t.*)/).flatten
    File.open( "#{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}", 'w' ) do |out|
        YAML.dump(commit_details, out) 
    end
end               

end
