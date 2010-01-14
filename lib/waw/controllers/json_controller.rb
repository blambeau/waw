require 'json'
module Waw
  #
  # Decorates a given controller and convert result as JSON unless stated
  # otherwise.
  #
  class JSONController
    include Rack::FindRackAppDelegator

    # Creates a controller instance
    def initialize(app)
      raise WAWError, "JSONController expects a delegation controller" if app.nil?
      @app = app
    end

    # Calls the delegation controller and encode its result in JSON
    def call(env)
      status, headers, body = @app.call(env)
      header = {} if headers.nil?
      headers['Content-Type'] = 'application/json' if headers['Content-Type'].nil? 
      body = ::JSON.generate(body) if json_response?(headers)
      [status, headers, body]
    end

    # Do i need to encode as JSON?
    def json_response?(headers)
      (headers['Content-Type'] == 'application/json')
    end

  end # class JSONController
end # module Waw
