module Waw
  
  #
  # Controller of a web application, designing a number of typical services.
  #
  class Controller
    include Waw::EnvironmentUtils
    include Rack::FindRackAppDelegator
    
    # Content type of the controller
    attr_accessor :content_type
    
    # Handler for Rack calls to the controller
    def call(env)
      req, res = Rack::Request.new(env), Rack::Response.new(env)
      Waw.logger.debug("Starting Waw::Controller.call with #{req.cookies.inspect}")
      
      # Save thread local variables
      Thread.current[:rack_env] = env
      Thread.current[:rack_request] = req
      Thread.current[:rack_response] = res

      # Execute controller
      result = execute(env, req, res)
      Waw.logger.debug("Waw::Controller serving #{result[0]} with headers #{result[1].inspect}")
      Waw.logger.debug("Session is now #{session.inspect}")
      result
    rescue Exception => ex
      # On exception, returns a 500 with a message
      Waw.logger.error("Fatal error #{ex.message}")
      Waw.logger.error(ex.backtrace.join("\n"))
      Waw.logger.error("Returning 500 with #{result}")
      [500, {'Content-Type' => content_type}, [ex.message]]
    ensure
      # In all cases, remove thread local variables
      Thread.current[:rack_env] = nil
      Thread.current[:rack_request] = nil
      Thread.current[:rack_response] = nil
    end
    
    # Executes the controller on a Rack::Request and Rack::Response pair
    def execute(env, request, response)
      raise "Should be subclassed"
    end
    
  end # class Controller

end # module Waw