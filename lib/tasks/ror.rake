
namespace :ror do
  task :environment do                                           
    project_folder = "#{ENV['PROJECT_NAME']}/".gsub(/[\s]/,"_")
    env = YAML.load_file(ENV['DRIVE_DIR']+project_folder+"environment.yml")
    missing_env_properties = %w{drive_dir source builds commit_report} - env.keys 
    raise "fatal: environment not set properly - missing: #{missing_env_properties.inspect}" unless missing_env_properties.empty?   
    %w{drive_dir source builds commit_report}.each do |var| 
      ENV[var] = env[var]
    end
  end
end
