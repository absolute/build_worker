module FileHelper
  module ClassMethods
    
  end
  
  module InstanceMethods
    def recreate_dir(dir)     
      puts dir
      system(%{rm -rf #{dir}}) if File.exists?(dir) 
      system(%{mkdir #{dir}}) 
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end