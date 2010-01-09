module Waw
  module Routing
    # Redirect routing
    class Redirect < RoutingRule
      
      # Creates a redirection rule instance
      def initialize(opts)
        raise ArgumentError, "Invalid options #{opts.inspect} for Redirect, missing url"\
          unless Hash===opts and opts.has_key?(:url)
        @opts = opts
      end
      
      # Forces the browser to refresh
      def apply_on_browser(browser)
        browser.location = @opts[:url]
      end
      
    end # class Redirect
  end # module Routing
end # module Waw