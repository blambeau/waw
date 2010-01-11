module Waw
  module Routing
    # Refresh routing
    class Refresh < RoutingRule

      # Forces the browser to refresh
      def apply_on_browser(result, browser)
        browser.refresh
      end
      
      def generate_js_code(result, align=0)
        " "*align + "location.reload(true);"
      end
      
    end # class Refresh
  end # module Routing
end # module Waw