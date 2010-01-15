require 'waw/controllers/static/waw_access'
require 'waw/controllers/static/waw_access_dsl'
module Waw
  # 
  # A waw service that serves public pages expressed in wlang wtpl format
  #
  class StaticController < ::Waw::Controller
  
    ##############################################################################################
    ### About service creation and configuration
    ##############################################################################################
  
    # Default options of this service
    DEFAULT_OPTIONS = {:root => 'public'}
  
    # Creates a service instance
    def initialize(opts = {})
      @options = DEFAULT_OPTIONS.merge(opts)
      @wawaccess = ::Waw::StaticController::WawAccess.load_hierarchy(File.join(Waw.root_folder, root_folder))
    end
  
    # Returns the template folder
    def root_folder
      @options[:root]
    end
  
    ##############################################################################################
    ### Main service execution
    ##############################################################################################

    # Executes the service
    def execute(env, req, res)
      @wawaccess.do_path_serve(env['PATH_INFO'])
    end

  end # class Controller
end # module Waw