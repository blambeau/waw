require 'fileutils'
module Waw
  
  # The rack application at top of the hierarchy
  class KernelApp
    include ::Rack::Delegator
    
    # The current business application
    attr_accessor :app
    
    # Creates a kernel instance
    def initialize(app = nil, options = {})
      @app, @options = app, options
    end
    
    # Converts a back-trace to a friendly HTML chunck
    def ex_backtrace_to_html(backtrace)
      "<div>" + backtrace.join('</div><div>') + "</div>"
    end
    
    # Converts an exception to a friendly HTML chunck
    def ex_to_html(ex)
      <<-EOF
        <html>
          <head>
            <style type="text/css">
              body {
                font-size: 14px;
              	font-family: "Courier", "Arial", sans-serif;
              }
              p.message {
                font-size: 16px;
                font-weight: bold;
              }
            </style>
          </head>
          <body>
            <h1>Internal server error (ruby exception)</h1>
            <p class="message"><code>#{ex.message}</code></p>
            <div style="margin-left:50px;">
              #{ex_backtrace_to_html(ex.backtrace)}
            </div>
          </body>
        </html>
      EOF
    end
    
    # Delegated to the real application, if loaded
    def call(env)
      # Save thread environment variables
      req, res = Rack::Request.new(env), Rack::Response.new(env)
      Thread.current[:rack_env] = env
      Thread.current[:rack_request] = req
      Thread.current[:rack_response] = res
      
      # Make the call
      if @app
        @app.call(env)
      else
        [503, {'Content-Type' => 'text/plain'}, ['This waw application is unloaded']]
      end
    rescue Exception => ex
      # On exception, returns a 500 with a message
      Waw.logger.error("Fatal error #{ex.message}")
      Waw.logger.error(ex.backtrace.join("\n"))
      [500, {'Content-Type' => 'text/html'}, [ex_to_html(ex)]]
    ensure
      # In all cases, remove thread local variables
      Thread.current[:rack_env] = nil
      Thread.current[:rack_request] = nil
      Thread.current[:rack_response] = nil
    end
    
  end # class KernelApp
  
  # Contains the loadstage kernel used by Waw.
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
    
    ################################################################# About the logger
    
    # Returns installed logger, or a default one on STDOUT
    def logger
      @logger || Logger.new(STDOUT)
    end
    
    ################################################################# About the kernel controller
    
    # Returns the kernel application or create one
    def kernel
      @kernel ||= ::Waw::KernelApp.new
    end
    
    # Deprecated, use kernel instead
    def app
      puts "WARNING: w@w kernel usage deprecated, use kernel instead (#{caller[0]})"
      kernel
    end
    
    # Deprecated, use Waw.kernel.app = 
    def app=(app)
      puts "WARNING: w@w kernel usage deprecated, use kernel.app= instead (#{caller[0]})"
      kernel.app = app
    end
    
    # Loads the rack application
    def rack(&block)
      kernel.app = ::Rack::Builder.new(&block).to_app
      kernel.app
    end
  
    # Finds the Rack application that matches a given path/block pair.
    def find_rack_app(path = nil, &block)
      kernel.find_rack_app(path, &block)
    end
  
    # Finds the URL of a given controller.
    def find_url_of(controller)
      kernel.find_url_of(controller)
    end

    ################################################################# About hooks
    
    # Installed hooks
    def hooks(which)
      @hooks = Hash.new{|h,k| h[k] = []} if @hooks.nil?
      @hooks[which]
    end
    
    # Adds a start hook
    def add_start_hook(hook)
      hooks(:start) << hook
    end
    
    # Adds a start hook
    def add_unload_hook(hook)
      hooks(:unload) << hook
    end
    
    # Execute an array of hooks
    def execute_hooks(which)
      # API installed hooks
      hooks(which).each do |hook|
        if hook.respond_to?(:run)
          hook.run
        elsif hook.respond_to?(:call)
          hook.call
        end
      end
      # the file ones now
      hooks_dir = File.join(root_folder, 'hooks', which.to_s)
      Dir[File.join(hooks_dir, '*.rb')].sort{|f1, f2| File.basename(f1) <=> File.basename(f2)}.each do |file|
        logger.info("Running waw #{which} hook #{file}...")
        Kernel.load(file)
      end
    end
    
    ################################################################# About loading
    
    # Autoloads waw from a given file or a root folder
    def autoload(file)
      if File.file?(file)
        @root_folder = File.expand_path(File.dirname(file))
      elsif File.directory?(file)
        @root_folder = File.expand_path(file)
      else
        raise WawError, "Invalid root folder #{file}, inexisting!", caller
      end
      puts "Autoloading waw web application from #{root_folder}"
      load_application(root_folder)
      kernel
    rescue ConfigurationError, WawError => ex
      raise ex
    rescue Exception => ex
      if logger
        logger.fatal(ex.class.name.to_s + " : " + ex.message)
        logger.fatal(ex.backtrace.join("\n"))
      end
      raise ex
    end

    # Loads the entire application from a given root folder.
    # If a block is given, yields it before considering the application
    # fully loaded.
    def load_application(root_folder, &block)
      self.root_folder = root_folder
      
      # 0) Load stage 0: waw.deploy
      self.deploy_words = load_deploy
      
      # 1) Load stage 1: config
      self.config = load_config
    
      # 2) Load stage 2: logger
      self.logger = load_logger
      logger.info("#{self.class.name}: load stage 1 sucessfull (#{deploy_words.join(', ')})")
      logger.info("#{self.class.name}: load stage 2 sucessfull")
    
      # 3) Load stage 3: resources
      self.resources = load_resources
      logger.info("#{self.class.name}: load stage 3 sucessfull")
      
      # 4) Load stage 4: rack application
      routing = load_routing
      logger.info("#{self.class.name}: load stage 4 sucessfull (using #{routing})")
    
      # 4) Load stage 5: start hooks
      execute_hooks(:start)
      logger.info("#{self.class.name}: load stage 5 sucessfull (start hooks executed)")
    
      # 5) yield next application loading if exists
      result = block_given? ? yield : self
      
      logger.info("#{self.class.name}: application loaded successfully, enjoy!")
      result
    end
    
    # Implements load stage #0: waw.deploy
    def load_deploy
      # Locates the waw.deploy file
      deploy_file = File.join(root_folder, 'waw.deploy')
      unless File.exists?(deploy_file)
        puts "wawdeploy is deprecated, use waw.deploy instead!"
        deploy_file = File.join(root_folder, 'wawdeploy')
      end
      raise ConfigurationError, "Missing waw.deploy file" unless File.exists?(deploy_file)
      
      words = []
      File.readlines(deploy_file).each do |line|
        next if /^#/ =~ (line = line.strip)
        next if line.empty?
        raise "Waw deploy file corrupted on line #{i} (#{line})" unless /^[a-z_]+(\s+[a-z_]+)*$/ =~ line
        words += line.split(/\s+/)
      end
      words
    end
    
    # Implements load stage #1: waw configuration
    def load_config
      # create a default configuration
      config = Waw::Config.new(true)
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
  
    # Implements load stage #2: logger
    def load_logger
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
  
    # Implements load stage #3: resources
    def load_resources
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
    
    # Implements load stage #4: routing
    def load_routing
      deploy_words.reverse.each do |word|
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
        logger.warn("Ignoring load stage #4, no waw.routing file found")
        "none"
      end
    end
  
    ################################################################# About unloading
    
    # Unloads the entire application
    def unload()
      execute_hooks(:unload)
      self.root_folder = nil
      self.deploy_words = nil
      self.config = nil
      self.resources = nil
      kernel.app = nil
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
    
  end # module App
end # module Waw