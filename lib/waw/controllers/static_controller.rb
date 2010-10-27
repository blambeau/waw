require 'uri'
require 'waw/controllers/static/waw_access'
require 'waw/controllers/static/waw_access_dsl'
require 'waw/controllers/static/matcher'
require 'waw/controllers/static/match'
module Waw
  # 
  # A waw service that serves public pages expressed in wlang wtpl format
  #
  class StaticController < ::Waw::Controller
  
    ##############################################################################################
    ### About service creation and configuration
    ##############################################################################################
  
    # Default options of this service
    DEFAULT_OPTIONS = {:public => 'public'}
  
    # Creates a service instance
    def initialize(opts = {})
      @options = DEFAULT_OPTIONS.merge(opts)
      @wawaccess = ::Waw::StaticController::WawAccess.load_hierarchy(File.join(root_folder, public_folder))
    end
  
    # Returns the template folder
    def public_folder
      @options[:public] || @options[:root]
    end
  
    ##############################################################################################
    ### Main service execution
    ##############################################################################################

    # Executes the service
    def call(env)
      @wawaccess.call(env)
    end

  end # class Controller
end # module Waw