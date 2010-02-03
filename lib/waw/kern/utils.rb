module Waw
  module Kern
    #
    # Utilities of the waw kernel
    #
    module Utils
      
      #
      # Finds the root of the waw application by traversing the file system
      # up from _from_ until a waw.deploy file can be found. Returns the 
      # root_folder that contains the waw.deploy file.
      #
      # This method raises a WawError if the waw.deploy file cannot be found.
      #
      def find_web_root(from)
        web_root = File.expand_path(from)
        from = File.dirname(from) if File.file?(from)
        until File.exists?(File.join(web_root, 'waw.deploy')) or File.exists?(File.join(web_root, 'wawdeploy'))
          web_root = File.expand_path(File.join(web_root, '..'))
          raise WawError, "Unable to find waw.deploy file from folder #{from}" if web_root == '/'
        end
        web_root
      end
    
    end # module Utils
  end # module Kern
end # module Waw