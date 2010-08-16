require "fileutils"                                       

namespace "ror" do

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
end               

end
