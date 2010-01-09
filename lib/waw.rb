require 'rubygems'
require 'rack'

require 'waw/ext'
require 'waw/validation'
require 'waw/environment_utils'
require 'waw/controller'
require 'waw/routing'
require 'waw/action'
require 'waw/action_controller'
module Waw
  
  VERSION = "0.0.1".freeze

  # Sets the logger to use for Waw itself
  def self.logger=(logger)
    @logger = logger
  end

  # Returns the logger to use  
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  extend Waw::EnvironmentUtils
end
