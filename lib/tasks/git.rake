require "fileutils"                                       

namespace "git" do
                                  
task :set_ssh_key, [:cfg] do |t, args|
  @cfg = args.cfg
  # ssh_folder = ENV['SSH_FOLDER']
    sh %{touch #{@cfg.ssh_config_to}} unless File.exists?(@cfg.ssh_config_to)
    sh %{chmod 600 #{@cfg.ssh_config_to}} unless File.exists?(@cfg.ssh_config_to)      
    if File.exists?(@cfg.ssh_config_to)
      system %{cat #{@cfg.ssh_config_from} >> #{@cfg.ssh_config_to}} unless (IO.readlines(@cfg.ssh_config_from)-IO.readlines(@cfg.ssh_config_to)).empty?
    else
      system %{cat #{@cfg.ssh_config_from} > #{@cfg.ssh_config_to}} unless File.exists?(@cfg.ssh_config_to)
    end
    sh %{cp #{@cfg.ssh_private_key_from} #{@cfg.ssh_private_key_to}} unless File.exists?(@cfg.ssh_private_key_to)
    sh %{cp #{@cfg.ssh_public_key_from} #{@cfg.ssh_public_key_to}} unless File.exists?(@cfg.ssh_public_key_to)
  # end                                                     
end

directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"

desc "build RubyOnRails project"
task :checkout, [:cfg] => [:set_ssh_key] do |t, args|                   
    @cfg = args.cfg
    Dir.chdir(@cfg.project_folder) do 
      sh %{git clone #{@cfg.project_uri} #{@cfg.source_folder} > #{@cfg.build_log} 2>&1}
    end            
end

# task :update, [:cfg] => [:set_ssh_key, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
#     source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
#     build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
#     Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
#         sh %{git pull origin master > ../#{ENV['BUILD_ID']}/build.log 2>&1}
#         sh %{git show --pretty=fuller --name-status > ../#{ENV['BUILD_ID']}/commit.report 2>../#{ENV['BUILD_ID']}/build.log}
#     end                                                        
#     commit_details = Hash.new()
#     out = File.new(build_folder+"commit.report").readlines(nil)[0]
#     commit_details["commit_id"] = out.scan(/commit\s+([^\n]+)/).flatten[0].strip
#     commit_details["commit_by"] = out.scan(/Commit:\s+([^\n]+)/).flatten[0].strip
#     commit_details["commit_on"] = out.scan(/CommitDate:\s+([^\n]+)/).flatten[0].strip
#     commit_details["commit_message"] = out.scan(/\n\n(.+)\n\n/).flatten[0].strip
#     commit_details["changed_files"] = out.scan(/([MAD]\t.*)/).flatten
#     File.open(build_folder+"commit.report", 'w' ) do |out|
#         YAML.dump(commit_details, out) 
#     end
# end               


task :update, [:cfg] => [:set_ssh_key, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do  |t, args| 
    @cfg = args.cfg
    # source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
    # build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
    Dir.chdir(@cfg.source_folder) do 
        sh %{git pull origin master > #{@cfg.build_log} 2>&1}
        sh %{git show --pretty=fuller --name-status > #{@cfg.commit_report} 2>#{@cfg.build_log}}
    end                                                        
    commit_details = Hash.new()
    out = File.new(@cfg.commit_report).readlines(nil)[0]
    commit_details["commit_id"] = out.scan(/commit\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_by"] = out.scan(/Commit:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_on"] = out.scan(/CommitDate:\s+([^\n]+)/).flatten[0].strip
    commit_details["commit_message"] = out.scan(/\n\n(.+)\n\n/).flatten[0].strip
    commit_details["changed_files"] = out.scan(/([MAD]\t.*)/).flatten
    File.open(@cfg.commit_report, 'w' ) do |out|
        YAML.dump(commit_details, out) 
    end
end               



end
