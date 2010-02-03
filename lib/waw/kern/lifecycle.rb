module Waw
  module Kern
    #
    # Implements waw kernel's lifecycle.
    #
    module Lifecycle
      
      #
      # Autoloads waw from a given location. The waw root_folder is found
      # using find_web_root and the application loaded using load_application.
      #
      # This method expects read/write accessors for the instance variables below. 
      # All these variables are expected to be initially nil and are affected when
      # the application is loaded (see load_application).
      #
      # * root_folder  : the expanded file name of the root folder of the application
      # * deploy_words : an array of deploy words found in waw.deploy
      # * config       : Waw::Config instance, merged with configuration files in turn
      # * logger       : Logger instance
      # * resources    : ResourceCollection instance, filled with resource files
      # * routing      : name of the waw.routing file that has been loaded
      # * app          : Rack application loaded thanks to the routing file.
      #
      def autoload(file)
        load_application(file)
      rescue ConfigurationError, WawError => ex
        raise ex
      rescue Exception => ex
        if logger
          logger.fatal(ex.class.name.to_s + " : " + ex.message)
          logger.fatal(ex.backtrace.join("\n"))
        end
        raise ex
      end

      #
      # Loads the entire application from a given root folder, each
      # load stage in turn:
      #
      #   -1. find_web_root(from)
      #    0. load_deploy
      #    1. load_config
      #    2. load_logger
      #    3. load_resources
      #    4. load_routing
      #    5. load_hooks
      #
      # Returns self. Raises a ConfigurationError if something fails.
      #
      def load_application(from)
        # 0) Load stage -1: finding web root
        self.root_folder = find_web_root(from)
      
        # 0) Load stage 0: waw.deploy
        self.deploy_words = load_deploy(root_folder)
      
        # 1) Load stage 1: config
        self.config = load_config(root_folder, deploy_words)
    
        # 2) Load stage 2: logger
        self.logger = load_logger(root_folder, deploy_words, config)
        logger.info("#{self.class.name}: load stage 1 sucessfull (#{deploy_words.join(', ')})")
        logger.info("#{self.class.name}: load stage 2 sucessfull")
    
        # 3) Load stage 3: resources
        self.resources = load_resources(root_folder, deploy_words, config, logger)
        logger.info("#{self.class.name}: load stage 3 sucessfull (resources)")
      
        # 4) Load stage 4: routing
        self.routing, self.app = load_routing(root_folder, deploy_words, config, logger, resources)
        logger.info("#{self.class.name}: load stage 4 sucessfull (using #{routing})")
    
        # 5) Load stage 5: load hooks
        execute_hooks(:load)
        execute_hooks(:start)
        logger.info("#{self.class.name}: load stage 5 sucessfull (load hooks executed)")
    
        # Hey hey, everything fine if we reach this!
        logger.info("#{self.class.name}: application loaded successfully, enjoy!")
        self
      end
    
      #
      # Implements load stage #0: waw.deploy
      #
      # This method loads the waw.deploy file, decodes it and returns an array 
      # of deploy words.
      #
      # Raises a ::Waw::ConfigurationError if waw.deploy cannot be found or is 
      # corrupted.
      #
      def load_deploy(root_folder)
        # Locates the waw.deploy file
        deploy_file = File.join(root_folder, 'waw.deploy')
        unless File.exists?(deploy_file)
          puts "wawdeploy is deprecated, use waw.deploy instead!"
          deploy_file = File.join(root_folder, 'wawdeploy')
        end
        raise ConfigurationError, "Missing waw.deploy file" unless File.exists?(deploy_file)
      
        words = []
        File.readlines(deploy_file).each_with_index do |line, i|
          next if /^#/ =~ (line = line.strip)
          next if line.empty?
          raise ConfigurationError, "Waw deploy file corrupted on line #{i} (#{line})"\
            unless /^[a-z_]+(\s+[a-z_]+)*$/ =~ line
          words += line.split(/\s+/)
        end
        words
      end
    
      #
      # Implements load stage #1: waw configuration
      #
      # This method merges all root_folder/config/xxx.cfg files (where xxx denotes 
      # a deploy word) inside the default waw configuration, which is then returned.
      #
      # Raises a ConfigurationError if a configuration file is missing or if something 
      # fails when loading a configuration file.
      #
      def load_config(root_folder, deploy_words)
        # create a default configuration
        config = Waw::Config.new(self, true)
        config.install_configuration_property(:root_folder, root_folder)
    
        # Read it and analyse merged configurations
        conf_file = nil
        deploy_words.each do |conf|
          conf_file = File.join(root_folder, 'config', "#{conf}.cfg")
          raise ConfigurationError, "Missing config file config/#{conf}.cfg" unless File.exists?(conf_file)
          config.merge_file(conf_file)
        end
    
        config
      rescue ConfigurationError => ex
        raise ex
      rescue Exception => ex
        raise ConfigurationError, "Error occured when loading configuration #{File.basename(conf_file)}\n#{ex.message}", ex.backtrace
      end
  
      #
      # Implements load stage #2: logger
      #
      # This method creates a logger instance with the config parameters
      # and returns it. 
      #
      # Raises a ConfigurationError if something fails.
      #
      def load_logger(root_folder, deploy_words, config)
        # default parameters
        appname = config.ensure(:application_name, 'webapp')
        log_frequency = config.ensure(:log_frequency, 'weekly')
      
        if config.knows?(:log_io)
          # We use a given IO
          logger = Logger.new(config.log_io, log_frequency)
        else
          # We go to a log file
          log_dir = config.ensure(:log_dir, 'logs')
          log_file = config.ensure(:log_file, "#{appname}.log")
        
          # Check it now
          FileUtils.mkdir_p(log_dir) unless File.exists?(log_dir)
          raise ConfigurationError, "Unable to use #{log_dir} for logs, it's a file..." unless File.directory?(log_dir)
          raise ConfigurationError, "Unable to use #{log_dir} for logs, not writable" unless File.writable?(log_dir)
        
          # The log file now
          log_file = File.join(config.log_dir, config.log_file)
          logger = Logger.new(log_file, log_frequency)
        end
        logger.level = config.ensure(:log_level, Logger::DEBUG)
        logger
      end
  
      #
      # Implements load stage #3: resources
      #
      # This method creates an empty ResourceCollection and fill it with
      # child collections, one for each resource files (.rs) found in 
      # root_folder/resources. Returns the parent collection.
      #
      # Riases a ConfigurationError if something fails.
      #
      def load_resources(root_folder, deploy_words, config, logger)
        resources = ResourceCollection.new
        resource_dir = File.join(root_folder, 'resources')
        if File.directory?(resource_dir) and File.readable?(resource_dir)
          Dir[File.join(resource_dir, '*.rs')].each do |file|
            name = File.basename(file, '.rs')
            resources.send(:add_resource, name, ResourceCollection.parse_resource_file(file))
            logger.debug("Resources #{name} loaded successfully")
          end
        elsif not(File.readable?(resource_dir))
          logger.warn("Ignoring the resources folder (not readable)... something will probably fail later!")
        end
        resources
      end
    
      # 
      # Implements load stage #4: routing
      #
      # This method locates the more specific waw.xxx.routing file, using deploy 
      # words in reverse order, and turning back to 'waw.routing' if no one can
      # be found. The corresponding routing file is then decoded and the Rack 
      # application built that way. 
      #
      # This method returns a pair [routing_file_name, rack_app].
      #
      # Raises a ConfigurationError if something fails (if the waw.routing file
      # cannot be found, in particular).
      #
      def load_routing(root_folder, deploy_words, config, logger, resources)
        deploy_words.reverse.each do |word|
          file = File.join(root_folder, "waw.#{word}.routing")
          return [File.basename(file), ::Kernel.eval(File.read(file))] if File.exists?(file)
        end
        file = File.join(root_folder, 'waw.routing')
        return ['waw.routing', ::Kernel.eval(File.read(file))] if File.exists?(file)
        raise ConfigurationError, "Unable to find waw.routing file in #{root_folder}"
      end
  
      ################################################################# About unloading
    
      # Unloads the entire application
      def unload()
        execute_hooks(:unload)
        self.root_folder = nil
        self.deploy_words = nil
        self.config = nil
        self.resources = nil
        self.routing = nil
        self.app = nil
        logger.info("#{self.class.name}: application unloaded successfully, ciao!")
        self.logger = nil
      end
    
      ################################################################# About reloading
    
      # Unloads and directly reloads the whole application
      def reload
        folder = self.root_folder
        unload
        autoload(folder)
      end
      
    end # module Loading
  end # module Kern
end # module Waw