module Waw
  module Routing
    # Refresh routing
    class Refresh < RoutingRule

      # Forces the browser to refresh
      def apply_on_browser(browser)
        browser.refresh
      end
      
    end # class Refresh
  end # module Routing
end # module Waw