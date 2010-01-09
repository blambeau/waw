require 'json'
module Waw
  module RackUtils
    class JSON
  
      def initialize app
        @app = app
      end
  
      def call env
        @status, @headers, @body = @app.call env
        @body = ::JSON.generate @body if json_response?
        [@status, @headers, @body]
      end
  
      def json_response?
        @headers['Content-Type'] == 'application/json' 
      end
  
    end
  end
end
