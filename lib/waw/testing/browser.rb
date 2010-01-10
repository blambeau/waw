require 'net/http'
require 'uri'
module Waw
  module Testing
    # A fake browser for waw application testing
    class Browser
      include Waw::Testing::HTMLAnalysis
      
      # Current browser location
      attr_reader :location
      
      # Current server response
      attr_reader :response
      
      # Creates a browser instance
      def initialize(location = nil)
        self.location = location if location
      end
      
      #################################################################### URI utilities
      
      # Checks if something is an URI
      def is_uri?(uri)
        URI::Generic===uri
      end
      
      # Ensures that something is an uri or convert it.
      def ensure_uri(uri)
        is_uri?(uri) ? uri : URI.parse(uri)
      end
      
      # Extracts the base of an URI
      def extract_base(uri)
        ensure_uri("#{uri.scheme}://#{uri.host}#{uri.port ? (':' + uri.port.to_s) : ''}/")
      end
      
      # Computes the new location if a relative uri is followed
      def relative_uri(uri)
        uri = ensure_uri(uri)
        if uri.path[0...1] == '/'
          new_location = base.dup
          new_location.path = uri.path
          new_location
        else
          raise ArgumentError, "This browser does not support real relative uri #{uri}"
        end
      end
      
      #################################################################### Query utilities
      
      # Looks for the base of the website
      def base
        @base ||= find_base
      end
      
      # Checks if the last request waw answered by a 404 not found
      def is404
        (Net::HTTPNotFound === response)
      end
      
      # Returns the current shown contents
      def contents
        response ? response.read_body : nil
      end
      alias :browser_contents :contents
      
      #################################################################### Location set
      
      # Go to a relative position
      def go_relative(uri)
        self.location = relative_uri(uri)
      end
      
      # Sets the current location
      def location=(loc)
        @location, @response = fetch(loc)
        @location
      end
      
      # Refreshes the browser
      def refresh
        fetch(location)
      end
      
      # Simulates a click. Support relative as well as absolute paths.
      # Raises a URI::InvalidURIError if the given href seems invalid.
      def click_href(href)
        uri = URI.parse(href)
        if uri.relative?
          go_relative(uri)
        else
          case uri.scheme
            when "http"
              self.location = href
            else
              raise ArgumentError, "This browser does not support #{href} location"
          end
        end
      end
      
      #################################################################### Server invocation utilities
      
      # Invokes a server service with arguments and decoding method
      def server_invoke(service, args, decode_method = nil)
        location, response = fetch(relative_uri(service), :post, args)
        response
      end
      
      #################################################################### Private section
      private 
      
      # Clean cache after fetch
      def clean_post_fetch
        @base = nil
      end
      
      # Fetchs a given location
      def fetch(uri, method = :get, data = {}, limit = 10)
        # You should choose better exception.
        raise 'HTTP redirect too deep' if limit == 0

        location = ensure_uri(uri)
        response = case method
          when :get
            Net::HTTP.get_response(location)
          when :post
            Net::HTTP.post_form(location, data)
          else
            raise ArgumentError, "Invalid fetch method #{method}"
        end
        result = case response
          when Net::HTTPSuccess     
            [location, response]
          when Net::HTTPRedirection 
            fetch(response['location'], limit - 1)
          when Net::HTTPNotFound
            [location, response]
          else
            raise "Unexpected response from web server #{response}"
        end
        clean_post_fetch
        result
      end
      
      # Finds the base of the current location
      def find_base
        if contents
          found = has_tag?("base", :href => ".*?")
          if found
            ensure_uri(found[:href])
          else
            extract_base(location)
          end
        else
          extract_base(location)
        end
      end
      
    end # class Browser
  end # module Testing
end # module Waw
