$waw_deprecated_io = nil
require 'singleton'
require 'waw/ext/core'
require 'waw/ext/rack'
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
  VERSION = "0.3.0".freeze
  
  # Waw loading mutex
  WAW_KERNELS_LOCK = Mutex.new
  
  # Loaded kernels
  KERNELS = []
  
  # Autoloads and returns a waw application
  def self.autoload(from)
    WAW_KERNELS_LOCK.synchronize {
      KERNELS << (app = ::Waw::Kern::App.new)
      app.autoload(from)
    }
  end
  
  # Loads a rack application
  def self.rack(&block)
    ::Rack::Builder.new(&block).to_app
  end
  
  # Returns the last loaded waw kernel
  deprecated "Waw.kernel will be removed in version 0.3.0"
  def self.kernel
    KERNELS.last
  end
  
  # Sets the current kernel
  deprecated "Waw.kernel= will be removed in version 0.3.0"
  def self.kernel=(kernel)
    KERNELS << kernel
  end
  
  # Install a logger on waw itself
  def self.logger=(logger)
    @logger = logger
  end
  
  # Returns the waw logger, which always works on STDOUT
  def self.logger
    @logger || (self.kernel && self.kernel.logger) || Logger.new(STDOUT)
  end
  
  # Install other deprecated methods now
  def self.method_missing(name, *args, &block)
    k = self.kernel
    if k and k.respond_to?(name)
      $waw_deprecated_io << "Waw.#{name} will be removed in version 0.3.0. "\
                            "Please use the current kernel instance instead." if $waw_deprecated_io
      k.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end
  
end

# Now, make ruby requires
require 'rubygems'
Waw::GEM_REQUIREMENTS.each_pair {|name, version|
  gem(name.to_s, version)
  require(name.to_s)
}
require 'waw/errors'
require 'waw/scope_utils'
require 'waw/ext'
require 'waw/utils/dsl_helper'
require 'waw/resource_collection'
require 'waw/config'
require 'waw/kern'
require 'waw/validation'
require 'waw/environment_utils'
require 'waw/fullstate'
require 'waw/session'
require 'waw/controller'
require 'waw/restart'
require 'waw/controllers/json_controller'
require 'waw/controllers/action_controller'
require 'waw/controllers/static_controller'
require 'waw/controllers/no_cache'
require 'waw/controllers/error_handler'
require 'waw/routing'