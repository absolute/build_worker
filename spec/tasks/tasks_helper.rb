module TasksHelper
  def mark_env
    @env_vars = ENV.keys 
  end
  def reset_env        
    ENV.keys.each {|k| ENV.delete(k) unless @env_vars.include?(k)}
  end  
end
