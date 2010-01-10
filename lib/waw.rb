require 'rubygems'
require 'rack'
require 'wlang'

require 'waw/errors'
require 'waw/ext'
require 'waw/resource_collection'
require 'waw/config'
require 'waw/validation'
require 'waw/rack_utils'
require 'waw/environment_utils'
require 'waw/controller'
require 'waw/routing'
require 'waw/action'
require 'waw/action_controller'
require 'waw/services'
require 'waw/testing'
require 'waw/app'
module Waw
  extend Waw::App
  extend Waw::EnvironmentUtils
  
  # Waw version
  VERSION = "0.0.1".freeze

  # Finds the Rack application that matches a given path
  def self.find_rack_app(path, &block)
    found = @app.find_rack_app(path)
    (found and block_given?) ? found.find_rack_app(nil, &block) : found
  end

  # Loads the Rack architecture now
  def self.load_rack(config)
    app = Rack::Builder.new do
      use Rack::CommonLogger, Waw.logger
      use Rack::ShowExceptions
    end
    if Waw.resources.has_resource?(:services)
      Waw.resources.services.each do |name, service|
        logger.info("Loading waw service #{name} (#{service}) into Rack")
        service.install_on_rack_builder(config, app)
      end
    else
      logger.warn("Waw installed without service (missing resources/services.cfg ?)")
    end
    app = app.to_app
    if config.rack_session
      app = Rack::Session::Pool.new(app, :domain       => config.web_domain,
                                         :expire_after => config.rack_session_expire)
    end
    @app = app
  end
  
  # Loads the entire waw web application
  def self.load_application(root_folder = '')
    super(root_folder) do |app|
      # 5) load the web architecture now
      self.logger.info("#{self.class.name}: start hooks successfuly executed, reaching load stage 5")
      load_rack(config)
    end
  rescue ConfigurationError => ex
    raise ex
  rescue Exception => ex
    if logger
      logger.fatal(ex.class.name.to_s + " : " + ex.message)
      logger.fatal(ex.backtrace.join("\n"))
    end
    raise ex
  end

end
