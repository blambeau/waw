module Waw
  module Routing
    class RoutingRule
      
      # Applies this routing rule on a Waw::WSpec::Browser instance.
      # By default, does nothing at all.
      def apply_on_browser(result, browser)
      end
      
      def generate_js_code(result, align=0)
        raise "RoutingRule #{self.class} does not support javascript code generation" 
      end
      
    end # RoutingRule
  end # module Routing
end # module Waw