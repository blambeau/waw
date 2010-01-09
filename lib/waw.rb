require 'rubygems'
require 'rack'
require 'wlang'

require 'waw/errors'
require 'waw/ext'
require 'waw/resource_collection'
require 'waw/config'
require 'waw/validation'
require 'waw/environment_utils'
require 'waw/controller'
require 'waw/routing'
require 'waw/action'
require 'waw/action_controller'
require 'waw/services'
require 'waw/testing'
module Waw
  
  # Waw version
  VERSION = "0.0.1".freeze

  # Loaded resources
  Resources = ResourceCollection.new

  # Returns waw loaded configuration
  def self.config
    @config
  end

  # Sets the logger to use for Waw itself
  def self.logger=(logger)
    @logger = logger
  end

  # Returns the logger to use  
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
  
  # Loads waw configuration and deployment
  def self.load_config(root_folder = '')
    # create an default configuration
    config = Waw::Config.new(true)
    
    # Locates the wawdeploy file
    deploy_file = File.join(root_folder, 'wawdeploy')
    raise ConfigurationError, "Missing deploy file #{deploy_file}" unless File.exists?(deploy_file)
    
    # Read it and analyse merged configurations
    File.readlines(deploy_file).each do |line|
      next if /^#/ =~ (line = line.strip)
      next if line.empty?
      raise "Waw deploy file corrupted on line #{i} (#{line})" unless /^[a-z_]+(\s+[a-z_]+)*$/ =~ line
      line.split(/\s+/).each do |conf|
        conf_file = File.join(root_folder, 'config', "#{conf}.cfg")
        raise "Missing config file config/#{conf}.cfg" unless File.exists?(conf_file)
        config.merge(conf_file)
      end
    end
    
    @config = config
  end
  
  # Loads the Rack architecture now
  def self.load_rack(config)
    app = Rack::Builder.new do
      use Rack::CommonLogger, Waw.logger
      use Rack::ShowExceptions
    end
    config.waw_services(true).each do |service|
      logger.info("Loading waw service #{service} into Rack")
      service.new.install_on_rack_builder(config, app)
    end
    if config.rack_session
      app = Rack::Session::Pool.new(app, :domain       => config.web_domain,
                                         :expire_after => config.rack_session_expire)
    end
    app
  end
  
  # Loads the entire waw web application
  def self.load_application(root_folder = '')
    return unless config = load_config(root_folder)
    
    # 1) Install logger now
    log_file = File.join(config.log_dir, config.log_file)
    self.logger = Logger.new(log_file, config.log_frequency)
    self.logger.level = config.log_level
    self.logger.info("Waw configuration loaded successfully, reaching load stage 2")
    
    # 2) Loading resources
    resource_dir = File.join(root_folder, 'resources')
    if File.directory?(resource_dir)
      Dir[File.join(resource_dir, '*.rs')].each do |file|
        name = File.basename(file, '.rs')
        Resources.add_resource(name, ResourceCollection.parse_resource_file(file))
      end
    end
    
    # 3) start hooks now
    start_hooks_dir = File.join(root_folder, 'hooks', 'start')
    Dir[File.join(start_hooks_dir, '*.rb')].each do |file|
      logger.info("Running waw start hook #{file}...")
      Kernel.load(file)
    end
    
    # 4) load the web architecture now
    self.logger.info("Start hooks successfully executed, reaching load stage 3")
    webapp = load_rack(config)
  rescue ConfigurationError => ex
    raise ex
  rescue Exception => ex
    logger.fatal(ex.class.name.to_s + " : " + ex.message)
    logger.fatal(ex.backtrace.join("\n"))
    false
  end

  extend Waw::EnvironmentUtils
end
