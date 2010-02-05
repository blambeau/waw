module Waw
  module Kern
    # Kernel waw application
    class App
      include ::Rack::Delegator
      include ::Waw::Kern::FreezedState
      include ::Waw::Kern::LivingState
      include ::Waw::Kern::Hooks
      include ::Waw::Kern::Utils
      include ::Waw::Kern::Lifecycle
      
      # Creates a kernel application instance
      def initialize(identifier = nil, options = {})
        @options = options
      end
    
      # Installs the environment and delegates to the business 
      # application
      def call(env)
        install_living_state(env)
        if app=self.app
          app.call(env)
        else
          [503, {'Content-Type' => 'text/plain'}, ['This waw application is unloaded']]
        end
      rescue ::WLang::Error => ex
        # On exception, returns a 500 with a message
        logger.error("Fatal error #{ex.message}")
        logger.error(ex.wlang_backtrace.join("\n"))
        logger.error(ex.backtrace.join("\n"))
        [500, {'Content-Type' => 'text/html'}, [ex_to_html(ex, ex.wlang_backtrace)]]
      rescue Exception => ex
        # On exception, returns a 500 with a message
        logger.error("Fatal error #{ex.message}")
        logger.error(ex.backtrace.join("\n"))
        [500, {'Content-Type' => 'text/html'}, [ex_to_html(ex, ex.backtrace)]]
      ensure
        clean_living_state
      end
      
      # Converts a back-trace to a friendly HTML chunck
      def ex_backtrace_to_html(backtrace)
        "<div>" + backtrace.collect{|s| CGI.escapeHTML(s)}.join('</div><div>') + "</div>"
      end
    
      # Converts an exception to a friendly HTML chunck
      def ex_to_html(ex, backtrace)
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
              <p class="message"><code>#{CGI.escapeHTML(ex.message)}</code></p>
              <div style="margin-left:50px;">
                #{ex_backtrace_to_html(backtrace)}
              </div>
            </body>
          </html>
        EOF
      end
      
      # Returns an identifier for this kernel application
      def identifier
        @identifier || "No identifier (#{root_folder}/#{routing})"
      end
    
    end # class App
  end # module Kern
end # module Waw