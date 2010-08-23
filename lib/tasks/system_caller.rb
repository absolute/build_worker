class SystemCaller
  def self.call(cmd)    
    puts "-------------------in system callers real method"
    system cmd
  end
end