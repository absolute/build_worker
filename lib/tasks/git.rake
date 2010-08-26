require "fileutils"                                       

namespace "git" do
                                  
task :set_ssh_key do
  ssh_folder = ENV['SSH_FOLDER']
    sh %{touch #{ssh_folder}config} unless File.exists?("#{ssh_folder}/config")
    sh %{chmod 600 #{ssh_folder}config} unless File.exists?("#{ssh_folder}/config")      
    if File.exists?("#{ssh_folder}config")
      system %{cat for_builds/sshkeys/ssh_config >> #{ssh_folder}config} unless (IO.readlines("for_builds/sshkeys/ssh_config")-IO.readlines("#{ssh_folder}config")).empty?
    else
      system %{cat for_builds/sshkeys/ssh_config > #{ssh_folder}config} unless File.exists?("#{ssh_folder}config")
    end
    sh %{cp for_builds/sshkeys/id_rsa.pureapp #{ssh_folder}} unless File.exists?("#{ssh_folder}/id_rsa.pureapp")
    sh %{cp for_builds/sshkeys/id_rsa.pureapp.pub #{ssh_folder}} unless File.exists?("#{ssh_folder}/id_rsa.pureapp.pub")
  # end                                                     
end

directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"

desc "build RubyOnRails project"
task :checkout => [:set_ssh_key, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do                   
    Dir.chdir(%{#{ENV["PROJECT_FOLDER"]}}) do 
      sh %{git clone #{ENV['PROJECT_URI']} source > #{ENV['BUILD_ID']}/build.log 2>&1}
    end            
end

task :update => [:set_ssh_key, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
    source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
    build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
    Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
        sh %{git pull origin master > ../#{ENV['BUILD_ID']}/build.log 2>&1}
        sh %{git show --pretty=fuller --name-status > ../#{ENV['BUILD_ID']}/commit.report 2>../#{ENV['BUILD_ID']}/build.log}
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
