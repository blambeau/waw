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
      Waw.logger.debug("Starting Waw::Controller.call")
      req, res = Rack::Request.new(env), Rack::Response.new(env)
      
      # Save thread local variables
      Thread.current[:rack_env] = env
      Thread.current[:rack_request] = req
      Thread.current[:rack_response] = res

      # Execute controller
      kind, result = execute(env, req, res)
      case kind
        when :bypass
          result
        when :no_bypass
          Waw.logger.debug("Returning 200 with #{result.inspect}")
          [200, {'Content-Type' => content_type}, result]
        else
          Waw.logger.fatal("Unexpected controller result #{kind}")
          raise "Unexpected result #{kind}"
      end
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