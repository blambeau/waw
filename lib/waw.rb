require 'rubygems'
require 'rack'
require 'wlang'

require 'waw/errors'
require 'waw/ext/rack_ext'
require 'waw/ext/ruby_ext'

require 'waw/resource_collection'
require 'waw/config'
require 'waw/validation'
require 'waw/app'
require 'waw/environment_utils'

require 'waw/controller'
require 'waw/controllers/json_controller'
require 'waw/controllers/action_controller'
require 'waw/controllers/static_controller'

require 'waw/routing'
require 'waw/testing'
require 'waw/wlang/waw_dialects'
module Waw
  extend Waw::App
  extend Waw::EnvironmentUtils
  
  # Waw version
  VERSION = "0.1.0".freeze
  
  # Sets the application
  def self.app=(app)
    @app = app
  end
  
  # Autoloads waw from a given file
  def self.autoload(file)
    @root_folder = File.expand_path(File.dirname(file))
    puts "Autoloading waw web application from #{root_folder}"
    load_application(root_folder)
    @app
  rescue ConfigurationError => ex
    raise ex
  rescue Exception => ex
    if logger
      logger.fatal(ex.class.name.to_s + " : " + ex.message)
      logger.fatal(ex.backtrace.join("\n"))
    end
    raise ex
  end
  
  # Loads the rack application
  def self.rack(&block)
    @app = ::Rack::Builder.new(&block).to_app
  end
  
  # Runned application
  def self.app
    @app
  end

  # Finds the Rack application that matches a given path/block pair.
  def self.find_rack_app(path = nil, &block)
    @app.find_rack_app(path, &block)
  end
  
  # Finds the URL of a given controller.
  def self.find_url_of(controller)
    @app.find_url_of(controller)
  end

end
