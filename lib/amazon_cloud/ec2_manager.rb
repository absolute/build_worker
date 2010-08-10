class EC2Manager
def initialize
  @idle_servers = []
  @busy_servers = []
end
def running_count
  return @idle_servers.size + @busy_servers.size
end

def get_server(project)                             
  throw :try_after_5_mins if (@idle_servers.empty? && !@busy_servers.empty? && project[:committed_on] > 5.minutes.ago)                                        
  @idle_servers.push({:instance_id => "in-123", :status => "running"}) if (@idle_servers.empty?)
  server = @idle_servers.pop
  @busy_servers.push(server)
  return server
end
end