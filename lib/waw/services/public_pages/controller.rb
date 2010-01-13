module Waw
  module Services
    module PublicPages
      # 
      # A waw service that serves public pages expressed in wlang wtpl format
      #
      class Controller < ::Waw::Controller
      
        # Service installation on a rack builder
        def factor_service_map(config, map)
          Waw.logger.info("Starting public service on #{root_folder}")
          map['/'] = self
          map
        end
      
        ##############################################################################################
        ### About service creation and configuration
        ##############################################################################################
      
        # Default options of this service
        DEFAULT_OPTIONS = {:root => 'public'}
      
        # Creates a service instance
        def initialize(opts = {})
          @options = DEFAULT_OPTIONS.merge(opts)
          @wawaccess = WawAccess.load_hierarchy(root_folder)
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
          @wawaccess.execute(env, req, res)
        end
    
      end # class Controller
    end # module PublicPages
  end # module Services
end # module Waw