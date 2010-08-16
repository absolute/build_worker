require "fileutils"                                       

namespace "svn" do
            
# All directories should end with /
desc "build RubyOnRails project"
task "checkout" do
    Dir.chdir(%{#{ENV["DRIVE_DIR"]}}) do 
      sh %{svn checkout #{ENV['PROJECT_URI']} #{ENV['PROJECT_NAME']}}
    end            
end
directory "#{ENV['BUILD_DIR']}"
task "update" => ["#{ENV['BUILD_DIR']}"] do     
    Dir.chdir(%{#{ENV['DRIVE_DIR']}#{ENV['PROJECT_NAME']}}) do 
        sh %{svn update}
        sh %{svn log --limit 1 -v > #{ENV['BUILD_DIR']}#{ENV['COMMIT_REPORT']}}
    end            
end               

end
