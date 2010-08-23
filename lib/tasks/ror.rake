require "config_error"

namespace :ror do
  task :environment do                                
    raise ConfigError, "missing environment property: BUILD_ID Please set ENV['BUILD_ID']" unless ENV.has_key?('BUILD_ID')
    mandatory_properties =  %w{PROJECT_SCM PROJECT_COMMAND}                                          
    env = YAML.load_file(ENV['ENV_FILE'])
    env.each do |key,value|
      if (key=="project") 
        value.each do |k,v| 
          ENV["#{key}_#{k}".upcase] = v.to_s
        end
      else 
        ENV["#{key}".upcase] = value.to_s
      end
    end                                            
    missing_env_properties = mandatory_properties - ENV.keys        
    raise ConfigError, "missing environment properties: #{missing_env_properties.inspect}" unless missing_env_properties.empty?  
  end    
  
  task :config => [:environment] do
    Rake::Task["repo:checkout"].invoke
    Rake::Task["ror:database_setup"].invoke("for_builds/" , ENV['PROJECT_FOLDER']+"source/config/")
    Rake::Task["ror:run_user_command"].invoke(ENV['PROJECT_COMMAND'])
  end                                                       
  
  task :create_build => [:environment] do
    Rake::Task["repo:update"].invoke
    Rake::Task["ror:database_setup"].invoke("for_builds/" , ENV['PROJECT_FOLDER']+"source/config/")
    Rake::Task["ror:run_user_command"].invoke(ENV['PROJECT_COMMAND'])
  end
  
  task :database_setup, :source, :target do |t,args|          
    FileUtils.ln_s "#{args.source}database.yml", "#{args.target}database.yml", :force => true if File.exists?("#{args.target}database.yml")
  end                                          
  
  task :run_user_command, :command do |t,args| 
    raise ConfigError, "ERROR: user command missing" if args.command.nil?
    Dir.chdir(ENV['PROJECT_FOLDER']) do
      %x{echo "Running '#{args.command}'" >#{ENV['BUILD_ID']}/build.status} 
      %x{#{args.command} >#{ENV['BUILD_ID']}/build.log 2>&1}
      raise StandardError, "ERROR: user command failed" unless $?.success?
      %x{echo "Finished '#{args.command}'" >#{ENV['BUILD_ID']}/build.status}
    end
  end
end
