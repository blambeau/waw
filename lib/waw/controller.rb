module Waw
  
  #
  # Controller of a web application, designing a number of typical services.
  #
  class Controller
    include Waw::EnvironmentUtils
    include ::Rack::Delegator
    
    # Handler for Rack calls to the controller
    def call(env)
      if config.deploy_mode == 'devel'
        logger.debug("Starting controller execution #{self.class}")
        logger.debug("Session is #{session.inspect}")
      end
      result = execute(env, request, response)
      raise WawError, "Controller #{self.class} returned an empty result" unless result
      raise WawError, "Controller #{self.class} returned an invalid result #{result.inspect}" unless Array===result
      if config.deploy_mode == 'devel'
        logger.debug("Successfull controller execution with #{result[0]}")
        logger.debug("Session is #{session.inspect}")
      end
      result
    end
    
    # Executes the controller on a Rack::Request and Rack::Response pair
    def execute(env, request, response)
      raise "Should be subclassed"
    end
    
  end # class Controller

end # module Waw