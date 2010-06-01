module Waw
  module Routing
    # Redirect routing
    class Redirect < RoutingRule
      
      # Creates a redirection rule instance
      def initialize(opts = {})
        @opts = opts
      end
      
      # Forces the browser to refresh
      def apply_on_browser(result, browser)
        browser.location = @opts[:url]
      end
      
      def generate_js_code(result, align=0)
        if @opts[:url]
          " "*align + "window.location = \"#{@opts[:url]}\";"
        else
          " "*align + "window.location = data[1];"
        end
      end
      
    end # class Redirect
  end # module Routing
end # module Waw