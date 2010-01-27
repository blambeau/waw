# 
# Main waw module, providing the strict micro kernel of waw loader
#
module Waw
  
  # Requirements on gems for this version
  GEM_REQUIREMENTS = {
    :rack  => '>= 1.1.0',
    :wlang => '>= 0.9.0',
    :json  => '>= 1.1.9'
  }
  
  # Waw version
  VERSION = "0.2.0".freeze
  
end

# Now, make ruby requires
require 'rubygems'
Waw::GEM_REQUIREMENTS.each_pair {|name, version|
  gem(name.to_s, version)
  require(name.to_s)
}
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

# Loads the waw kernel now
module Waw
  extend Waw::App
end
