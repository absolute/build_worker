require "fileutils"                                       

namespace "svn" do
task :auth, [:cfg] do  |t, args| 
  @cfg = args.cfg 
  if @cfg.auth_type=='password'                                                              
    @username_password = "--username=#{@cfg.username} --password=#{@cfg.password} --no-auth-cache --non-interactive"
  else
    @username_password = ""
  end            
end

directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"

# directory "#{args.cfg.build_folder}"
            
# All directories should end with /
# desc "build RubyOnRails project"
# task :checkout, [:cfg] => [:auth, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do |t, args|         
#   Dir.chdir(%{#{ENV["PROJECT_FOLDER"]}}) do 
#     sh %{svn checkout  #{@username_password} #{ENV['PROJECT_URI']} source > #{ENV['BUILD_ID']}/build.log 2>&1}
#   end            
# end     
# 
# task :update => [:auth, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
#     source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
#     build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
#     Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
#       sh %{svn #{@username_password} update > ../#{ENV['BUILD_ID']}/build.log 2>&1}
#       sh %{svn #{@username_password} log --limit 1 -v  > ../#{ENV['BUILD_ID']}/commit.report 2>../#{ENV['BUILD_ID']}/build.log}
#     end                                                        
#     commit_details = Hash.new()
#     out = File.new(build_folder+"commit.report").readlines(nil)[0]
#     row = out.scan(/\n([^|]+)\|([^|]+)\|([^|]+)\|[^\n]+/).flatten
#     commit_details["commit_id"] = row[0].strip
#     commit_details["commit_by"] = row[1].strip
#     commit_details["commit_on"] = row[2].strip
#     commit_details["commit_message"] = out.scan(/\n\n(.+)\n/).flatten[0].strip
#     commit_details["changed_files"] = out.scan(/\n\s+([MAD] .*)/).flatten
#     File.open(build_folder+"commit.report", 'w' ) do |out|
#         YAML.dump(commit_details, out) 
#     end
# end               
                

desc "build RubyOnRails project"
task :checkout, [:cfg] => [:auth] do |t, args|         
  @cfg = args.cfg
  Dir.chdir(@cfg.project_folder) do 
    sh %{svn checkout  #{@username_password} #{@cfg.project_uri} source > #{@cfg.build_log} 2>&1}
  end            
end

task :update, [:cfg] => [:auth] do |t, args|   
    @cfg = args.cfg
    Dir.chdir(@cfg.source_folder) do 
      sh %{svn #{@username_password} update > #{@cfg.build_log} 2>&1}
      sh %{svn #{@username_password} log --limit 1 -v  > #{@cfg.commit_report} 2>#{@cfg.build_log}}
    end                                                        
    commit_details = Hash.new()
    out = File.new(@cfg.commit_report).readlines(nil)[0]
    row = out.scan(/\n([^|]+)\|([^|]+)\|([^|]+)\|[^\n]+/).flatten
    commit_details["commit_id"] = row[0].strip
    commit_details["commit_by"] = row[1].strip
    commit_details["commit_on"] = row[2].strip
    commit_details["commit_message"] = out.scan(/\n\n(.+)\n/).flatten[0].strip
    commit_details["changed_files"] = out.scan(/\n\s+([MAD] .*)/).flatten
    File.open(@cfg.commit_report, 'w' ) do |out|
        YAML.dump(commit_details, out) 
    end
end               

end
