require "fileutils"                                       

namespace "svn" do
            
# All directories should end with /
desc "build RubyOnRails project"
task "checkout" do         
  Dir.chdir(%{#{ENV["PROJECT_FOLDER"]}}) do 
    sh %{svn checkout #{ENV['PROJECT_URI']} source}
  end            
end     

directory "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"
task "update" => ["#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}"] do   
    source_folder = "#{ENV['PROJECT_FOLDER']}source/"  
    build_folder = "#{ENV['PROJECT_FOLDER']}#{ENV['BUILD_ID']}/"  
    Dir.chdir("#{ENV['PROJECT_FOLDER']}source/") do 
      sh %{svn update}
      sh %{svn log --limit 1 -v > ../#{ENV['BUILD_ID']}/commit.report}
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
