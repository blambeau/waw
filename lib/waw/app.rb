module Waw
  # Contains all methods to become a waw-config inspired application.
  module App
    
    # Configuration, when loaded
    attr_accessor :config
    
    # Logger, when loaded
    attr_accessor :logger
    
    # Resources, when loaded
    attr_accessor :resources
    
    # Loads waw configuration and deployment
    def load_config(root_folder = '')
      # create an default configuration
      config = Waw::Config.new(true)
      config.install_configuration_property(:root_folder, root_folder)
    
      # Locates the wawdeploy file
      deploy_file = File.join(root_folder, 'wawdeploy')
      raise ConfigurationError, "Missing deploy file #{deploy_file}" unless File.exists?(deploy_file)
    
      # Read it and analyse merged configurations
      conf_file = deploy_file
      File.readlines(deploy_file).each do |line|
        next if /^#/ =~ (line = line.strip)
        next if line.empty?
        raise "Waw deploy file corrupted on line #{i} (#{line})" unless /^[a-z_]+(\s+[a-z_]+)*$/ =~ line
        line.split(/\s+/).each do |conf|
          conf_file = File.join(root_folder, 'config', "#{conf}.cfg")
          raise ConfigurationError, "Missing config file config/#{conf}.cfg" unless File.exists?(conf_file)
          config.merge_file(conf_file)
        end
      end
    
      config
    rescue ConfigurationError => ex
      raise ex
    rescue Exception => ex
      raise ConfigurationError, "Error occured when loading configuration #{File.basename(conf_file)}\n#{ex.message}", ex.backtrace
    end
  
    # Loads the logger
    def load_logger(app)
      config = app.config
      log_file = File.join(config.log_dir, config.log_file)
      logger = Logger.new(log_file, config.log_frequency)
      logger.level = config.log_level
      logger
    end
  
    # Loads the resources
    def load_resources(app)
      resources = ResourceCollection.new
      resource_dir = File.join(app.config.root_folder, 'resources')
      if File.directory?(resource_dir)
        Dir[File.join(resource_dir, '*.rs')].each do |file|
          name = File.basename(file, '.rs')
          resources.send(:add_resource, name, ResourceCollection.parse_resource_file(file))
        end
      end
      resources
    end
  
    # Executes the start hooks
    def execute_start_hooks(app)
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
      # 1) Load stage 1: config
      self.config = load_config(root_folder)
    
      # 2) Load stage 2: logger
      self.logger = load_logger(self)
    
      # 3) Load stage 3: resources
      logger.info("#{self.class.name}: configuration and logger loaded successfuly, reaching load stage 3")
      self.resources = load_resources(self)
    
      # 4) start hooks now
      logger.info("#{self.class.name}: resources successfuly loaded, reaching load stage 4")
      execute_start_hooks(self)
    
      # 5) yield next application loading if exists
      result = block_given? ? yield(self) : self
      
      logger.info("#{self.class.name}: application loaded successfuly")
      result
    end
    
  end # module App
end # module Waw