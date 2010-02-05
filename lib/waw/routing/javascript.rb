module Waw
  module Routing
    # Javascript routing
    class Javascript < RoutingRule

      # Creates a javascript instance
      def initialize(code)
        @code = code
      end

      def generate_js_code(result, align=0)
        @code
      end
      
    end # class Javascript
  end # module Routing
end # module Waw