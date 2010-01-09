require 'net/http'
require 'uri'
module Waw
  module Testing
    # A fake browser for waw application testing
    class Browser
      
      # Current browser location
      attr_reader :location
      
      # Current server response
      attr_reader :response
      
      # Creates a browser instance
      def initialize(location = nil)
        self.location = location if location
      end
      
      # Sets the current location
      def location=(loc)
        fetch(loc)
        @location
      end
      
      # Refreshes the browser
      def refresh
        fetch(@location)
      end
      
      # Fetchs a given location
      def fetch(uri_str, limit = 10)
        # You should choose better exception.
        raise 'HTTP redirect too deep' if limit == 0

        @location, @response = uri_str, Net::HTTP.get_response(URI.parse(uri_str))
        case response
          when Net::HTTPSuccess     then @response
          when Net::HTTPRedirection then fetch(@response['location'], limit - 1)
          else
            raise "Unexpected response from web server #{response}"
        end
        true
      end
      
      # Returns the current shown contents
      def contents
        @response ? @response.read_body : nil
      end
      
    end # class Browser
  end # module Testing
end # module Waw
