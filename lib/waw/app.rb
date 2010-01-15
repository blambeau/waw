module Waw
  #
  # Contains the loadstage kernel used by Waw.
  #
  module App
    
    # The root folder of the running application
    attr_accessor :root_folder
    
    # All deployment words (seen in wawdeploy files, kept in reverse order)
    attr_accessor :deploy_words
    
    # Configuration, when loaded (see Config)
    attr_accessor :config
    
    # Logger
    attr_writer :logger
    
    # Resources (see ResourceCollection)
    attr_accessor :resources
    
    # Installed start hooks
    def start_hooks
      @start_hooks ||= []
    end
    
    # Adds a start hook
    def add_start_hook(hook)
      start_hooks << hook
    end
    
    # Returns installed logger, or a default one on STDOUT
    def logger
      @logger || Logger.new(STDOUT)
    end
    
    #
    # Implements load stage #1: waw configuration and deployment.
    # 
    # - Looks for wawdeploy file in the root folder
    # - For each word in this wawdeploy file, merge config/#{word}.cfg inside
    #   a fresh new Config instance.
    #
    # Raises a ConfigurationError if one of these files is missing.
    #
    def load_config(root_folder = '')
      # create an default configuration
      config = Waw::Config.new(true)
      config.install_configuration_property(:root_folder, root_folder)
    
      # Locates the wawdeploy file
      deploy_file = File.join(root_folder, 'wawdeploy')
      raise ConfigurationError, "Missing deploy file #{deploy_file}" unless File.exists?(deploy_file)
    
      # Read it and analyse merged configurations
      @deploy_words = []
      conf_file = deploy_file
      File.readlines(deploy_file).each do |line|
        next if /^#/ =~ (line = line.strip)
        next if line.empty?
        raise "Waw deploy file corrupted on line #{i} (#{line})" unless /^[a-z_]+(\s+[a-z_]+)*$/ =~ line
        line.split(/\s+/).each do |conf|
          conf_file = File.join(root_folder, 'config', "#{conf}.cfg")
          raise ConfigurationError, "Missing config file config/#{conf}.cfg" unless File.exists?(conf_file)
          config.merge_file(conf_file)
          @deploy_words.unshift(conf)
        end
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
    def load_logger(app)
      config = app.config
      
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
        File.makedirs(log_dir) unless File.exists?(log_dir)
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
    def load_resources(app)
      resources = ResourceCollection.new
      resource_dir = File.join(app.config.root_folder, 'resources')
      if File.directory?(resource_dir) and File.readable?(resource_dir)
        Dir[File.join(resource_dir, '*.rs')].each do |file|
          name = File.basename(file, '.rs')
          resources.send(:add_resource, name, ResourceCollection.parse_resource_file(file))
          app.logger.debug("Resources #{name} loaded successfully")
        end
      elsif not(File.readable?(resource_dir))
        app.logger.warn("Ignoring the resources folder (not readable)... something will probably fail later!")
      end
      resources
    end
    
    #
    # Implements load stage #4: routing
    #
    def load_routing(app)
      deploy_words.each do |word|
        file = File.join(root_folder, "waw.#{word}.routing")
        if File.exists?(file)
          Kernel.load(file) 
          return File.basename(file)
        end
      end
      file = File.join(root_folder, 'waw.routing')
      if File.exists?(file)
        Kernel.load(file)
        'waw.routing'
      else
        app.logger.warn("Ignoring load stage #4, no waw.routing file found")
        "none"
      end
    end
  
    # Executes the start hooks
    def execute_start_hooks(app)
      # the API ones
      start_hooks.each do |h|
        h.run
      end
      
      # the file ones now
      start_hooks_dir = File.join(app.config.root_folder, 'hooks', 'start')
      Dir[File.join(start_hooks_dir, '*.rb')].sort{|f1, f2| File.basename(f1) <=> File.basename(f2)}.each do |file|
        logger.info("Running waw start hook #{file}...")
        Kernel.load(file)
      end
    end
    
    # Loads the entire application from a given root folder.
    # If a block is given, yields it before considering the application
    # fully loaded.
    def load_application(root_folder, &block)
      self.root_folder = root_folder
      
      # 1) Load stage 1: config
      self.config = load_config(root_folder)
    
      # 2) Load stage 2: logger
      self.logger = load_logger(self)
      logger.info("#{self.class.name}: load stage 1 sucessfull (#{deploy_words.join(', ')})")
      logger.info("#{self.class.name}: load stage 2 sucessfull")
    
      # 3) Load stage 3: resources
      self.resources = load_resources(self)
      logger.info("#{self.class.name}: load stage 3 sucessfull")
      
      # 4) Load stage 4: rack application
      routing = load_routing(self)
      logger.info("#{self.class.name}: load stage 4 sucessfull (using #{routing})")
    
      # 4) Load stage 5: start hooks
      execute_start_hooks(self)
      logger.info("#{self.class.name}: load stage 5 sucessfull (start hooks executed)")
    
      # 5) yield next application loading if exists
      result = block_given? ? yield(self) : self
      
      logger.info("#{self.class.name}: application loaded successfully, enjoy!")
      result
    end
    
  end # module App
end # module Waw