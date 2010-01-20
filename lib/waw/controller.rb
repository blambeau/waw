module Waw
  
  #
  # Controller of a web application, designing a number of typical services.
  #
  class Controller
    include Waw::EnvironmentUtils
    include Rack::FindRackAppDelegator
    
    # Converts a back-trace to a friendly HTML chunck
    def ex_backtrace_to_html(backtrace)
      "<div>" + backtrace.join('</div><div>') + "</div>"
    end
    
    # Converts an exception to a friendly HTML chunck
    def ex_to_html(ex)
      <<-EOF
        <html>
          <head>
            <style type="text/css">
              body {
                font-size: 14px;
              	font-family: "Courier", "Arial", sans-serif;
              }
              p.message {
                font-size: 16px;
                font-weight: bold;
              }
            </style>
          </head>
          <body>
            <h1>Internal server error (ruby exception)</h1>
            <p class="message"><code>#{ex.message}</code></p>
            <div style="margin-left:50px;">
              #{ex_backtrace_to_html(ex.backtrace)}
            </div>
          </body>
        </html>
      EOF
    end
    
    # Handler for Rack calls to the controller
    def call(env)
      req, res = Rack::Request.new(env), Rack::Response.new(env)
      #Waw.logger.debug("Starting Waw::Controller.call with #{req.cookies.inspect}")
      
      # Save thread local variables
      Thread.current[:rack_env] = env
      Thread.current[:rack_request] = req
      Thread.current[:rack_response] = res

      # Execute controller
      result = execute(env, req, res)
      raise WawError, "Controller #{self.class} returned an empty result" unless result
      raise WawError, "Controller #{self.class} returned an invalid result #{result.inspect}" unless Array===result
      result
    rescue Exception => ex
      # On exception, returns a 500 with a message
      Waw.logger.error("Fatal error #{ex.message}")
      Waw.logger.error(ex.backtrace.join("\n"))
      Waw.logger.error("Returning 500 with #{result}")
      [500, {'Content-Type' => 'text/html'}, [ex_to_html(ex)]]
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