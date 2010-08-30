require "fileutils"                                       

namespace "svn" do
task :auth do                                                                                                           
  if ENV['AUTH_TYPE']=='password'                                                              
    @username_password = "--username=#{ENV['USERNAME']} --password=#{ENV['PASSWORD']} --no-auth-cache --non-interactive"
  else
    @username_password = ""
  end            
end

directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"
            
# All directories should end with /
desc "build RubyOnRails project"
task :checkout => [:auth, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do         
  Dir.chdir(%{#{ENV["PROJECT_FOLDER"]}}) do 
    sh %{svn checkout  #{@username_password} #{ENV['PROJECT_URI']} source > #{ENV['BUILD_ID']}/build.log 2>&1}
  end            
end     

task :update => [:auth, "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
    source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
    build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
    Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
      sh %{svn #{@username_password} update > ../#{ENV['BUILD_ID']}/build.log 2>&1}
      sh %{svn #{@username_password} log --limit 1 -v  > ../#{ENV['BUILD_ID']}/commit.report 2>../#{ENV['BUILD_ID']}/build.log}
    end                                                        
    commit_details = Hash.new()
    out = File.new(build_folder+"commit.report").readlines(nil)[0]
    row = out.scan(/\n([^|]+)\|([^|]+)\|([^|]+)\|[^\n]+/).flatten
    commit_details["commit_id"] = row[0].strip
    commit_details["commit_by"] = row[1].strip
    commit_details["commit_on"] = row[2].strip
    commit_details["commit_message"] = out.scan(/\n\n(.+)\n/).flatten[0].strip
    commit_details["changed_files"] = out.scan(/\n\s+([MAD] .*)/).flatten
    File.open(build_folder+"commit.report", 'w' ) do |out|
        YAML.dump(commit_details, out) 
    end
end               



# directory "#{ENV['BUILD_DIR']}"
# task "update" => ["#{ENV['BUILD_DIR']}"] do     
#     Dir.chdir(%{#{ENV['DRIVE_DIR']}#{ENV['PROJECT_NAME']}}) do 
#         sh %{svn update}
#         sh %{svn log --limit 1 -v > #{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}}
#     end            
#     commit_details = Hash.new()
#     out = File.new("#{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}").readlines(nil)[0]
#     row = out.scan(/\n([^|]+)\|([^|]+)\|([^|]+)\|[^\n]+/).flatten
#     commit_details["commit_id"] = row[0].strip
#     commit_details["commit_by"] = row[1].strip
#     commit_details["commit_on"] = row[2].strip
#     commit_details["commit_message"] = out.scan(/\n\n(.+)\n/).flatten[0].strip
#     commit_details["changed_files"] = out.scan(/\n\s+([MAD] .*)/).flatten
#     File.open( "#{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}", 'w' ) do |out|
#         YAML.dump(commit_details, out) 
#     end
#     
# end               

end
