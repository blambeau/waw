require 'net/http'
require 'uri'
module Waw
  module WSpec
    # A fake browser for waw application testing
    class Browser
      include Waw::WSpec::HTMLAnalysis
      
      # Current browser location
      attr_reader :location
      
      # Current server response
      attr_reader :response
      
      # The last action result
      attr_reader :last_action_result
      
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
        raise ArgumentError, "ensure_uri: uri may not be nil" if uri.nil?
        is_uri?(uri) ? uri : URI.parse(uri)
      end
      
      # Extracts the base of an URI
      def extract_base(uri)
        raise ArgumentError, "extract_base: uri may not be nil" if uri.nil?
        ensure_uri("#{uri.scheme}://#{uri.host}#{uri.port ? (':' + uri.port.to_s) : ''}/")
      end
      
      # Computes the new location if a relative uri is followed
      def relative_uri(uri)
        raise ArgumentError, "relative_uri: uri may not be nil" if uri.nil?
        uri = ensure_uri(uri)
        if uri.path[0...1] == '/'
          new_location = base.dup
          new_location.path = uri.path
          new_location.query = uri.query
          new_location
        else
          new_location = base.dup
          new_location.path = '/' + uri.path
          new_location.query = uri.query
          new_location
        end
      end
      
      #################################################################### Query utilities
      
      # Looks for the base of the website
      def base
        @base ||= find_base
      end
      
      # Finds the base of the current location
      def find_base
        if contents and (found = tag("base", {:href => /.*/}, contents))
          ensure_uri(found[:href])
        else
          extract_base(location)
        end
      end
      
      # Checks if the last request waw answered by a 404 not found
      def is404
        (Net::HTTPNotFound === response)
      end
      alias :is404? :is404
      
      # Checks if the last request waw answered by a 200 OK
      def is200
        (Net::HTTPSuccess === response)
      end
      alias :is200? :is200
      
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
        if (loc = ensure_uri(loc)).relative?
          go_relative(loc)
        else
          @location, @response = fetch(loc)
          @location
        end
      end
      
      # Fetches the headers only and returns it without keeping the result in browser
      # state
      def headers_fetch(uri)
        # Fetch the result at that location
        if (loc = ensure_uri(uri)).relative?
          headers_fetch(relative_uri(uri))
        else
          response = Net::HTTP.start(loc.host, loc.port) do |http|
            headers = @cookie ? {'Cookie' => @cookie} : {}
            http.head(loc.path, headers)
          end
        end
      end
      
      # Refreshes the browser
      def refresh
        self.location = location
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
      
      # Applies the action routing for a given action
      def apply_action_routing(action, result)
        @last_action_result = result
        action.routing.apply_on_browser(result, self) if action.routing
        result.extend(Waw::Routing::Methods)
        result
      end        
      
      # Invokes an action server side, decodes json response an applies action routing. 
      # Returns the action result.
      def invoke_action(action, args = {})
        raise ArgumentError, "Browser.invoke_action expects an ActionController::Action as first parameter"\
          unless ::Waw::ActionController::Action===action
        location, response = fetch(relative_uri(action.uri), :post, args)
        apply_action_routing(action, JSON.parse(response.body))
        self.response
      end
      
      # Invokes a service server side and returns HTTP response
      def invoke_service(service, args = {})
        raise ArgumentError, "Browser.invoke_service expects a String as first parameter"\
          unless String===service
        location, response = fetch(relative_uri(service), :post, args)
        self.response
      end
      
      # Invokes a server service with arguments and decoding method
      def server_invoke(service, args, decode_method = nil)
        location, response = fetch(relative_uri(service), :post, args)
        response
      end
      
      #################################################################### Private section
      # Clean cache after fetch
      def clean_post_fetch
        @base = nil
      end
      
      # Fetchs a given location
      def fetch(uri, method = :get, data = {}, limit = 10)
        # You should choose better exception.
        raise 'HTTP redirect too deep' if limit == 0

        # Fetch the result at that location
        location = ensure_uri(uri)
        response = Net::HTTP.start(location.host, location.port) do |http|
          headers = @cookie ? {'Cookie' => @cookie} : {}
          case method
            when :get
              path = location.path
              path += '?' + location.query if location.query
              http.request_get(path, headers)
            when :post
              req = Net::HTTP::Post.new(location.path, headers)
              req.form_data = data.unsymbolize_keys
              http.request(req)
            else
              raise ArgumentError, "Invalid fetch method #{method}"
          end
        end
        
        # If a cookie is requested save it
        @cookie = response['set-cookie']
        
        # Catch the response, following redirections
        result = case response
          when Net::HTTPRedirection 
            fetch(response['location'] || response['Location'], :get, {}, limit - 1)
          else
            [location, response]
        end
        
        # Cleans cache and returns result
        clean_post_fetch
        result
      end
      
      #################################################################### Helpers to save context
      
      # Installs the browser context
      def install_context(location, response, cookie)
        @location, @response, @cookie = location, response, cookie
        self
      end
      
      # Duplicates this browser instance, with internal state  
      def dup
        Browser.new.install_context(@location, @response, @cookie)
      end
      
    end # class Browser
    class ServerError < StandardError; end
  end # module WSpec
end # module Waw
