require 'rubygems'
require 'rack'
require 'wlang'

require 'waw/errors'
require 'waw/ext'
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
  
  VERSION = "0.0.1".freeze

  # Returns waw loaded configuration
  def self.config
  end

  # Sets the logger to use for Waw itself
  def self.logger=(logger)
    @logger = logger
  end

  # Returns the logger to use  
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
  
  # Starts the waw web application
  def self.start(root_folder = '')
    # create an default configuration
    config = Waw::Config.new(true)
    
    # Locates the wawdeploy file
    deploy_file = File.join(root_folder, 'wawdeploy')
    raise ConfigurationError, "Missing deploy file" unless File.exists?(deploy_file)
    
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
    true
  end

  extend Waw::EnvironmentUtils
end
