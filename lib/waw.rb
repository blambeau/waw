require 'rubygems'
require 'rack'
require 'wlang'
require 'singleton'

require 'waw/errors'
require 'waw/ext/rack_ext'
require 'waw/ext/ruby_ext'
require 'waw/utils/dsl_helper'

require 'waw/resource_collection'
require 'waw/config'
require 'waw/validation'
require 'waw/app'
require 'waw/environment_utils'
require 'waw/fullstate'
require 'waw/session'

require 'waw/controller'
require 'waw/restart'
require 'waw/controllers/json_controller'
require 'waw/controllers/action_controller'
require 'waw/controllers/static_controller'

require 'waw/routing'
require 'waw/testing'
module Waw
  extend Waw::App
  extend Waw::EnvironmentUtils
  
  # Waw version
  VERSION = "0.1.1".freeze
  
end
