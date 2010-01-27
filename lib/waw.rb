require 'rubygems'
gem 'rack', ">= 1.1.0"
gem 'wlang', ">= 0.9.0"
require 'rack'
require 'wlang'
require 'singleton'

require 'waw/errors'
require 'waw/scope_utils'
require 'waw/ext'
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
module Waw
  extend Waw::App
  
  # Waw version
  VERSION = "0.2.0".freeze
  
end
