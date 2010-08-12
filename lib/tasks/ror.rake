require "fileutils"                                       

namespace "ror" do

desc "build RubyOnRails project"
task "checkout" do
  Dir.chdir(%{#{ENV["DRIVE_DIR"]}}) do 
    res = sh %{git clone #{ENV['PROJECT_URI']} #{ENV['PROJECT_NAME']}}
  end            
end
task "build" do
    puts "------------------------------------BUILD BEGIN----------"
    verbose(true) do
      Dir.chdir(%{#{ENV["DRIVE_DIR"]}/#{ENV['PROJECT_NAME']}}) do 
        res = sh %{git fetch origin master}
      end            
    end
    puts "------------------------------------BUILD END----------"
end               

end
