require 'time'
module Waw
  class NoCache < ::Waw::Controller
    
    # What is sent to the headers
    NO_CACHE_HEADERS = {'Cache-control' => "no-store, no-cache, must-revalidate", 
                        'Pragma'        => "no-cache"}
    
    # Creates a application instance
    def initialize(app)
      @app = app
    end
    
    # Manage calls
    def call(env)
      status, headers, body = @app.call(env)
      headers = NO_CACHE_HEADERS.merge('Expires' => Time.now.rfc2822).merge(headers)
      [status, headers, body]
    end
    
  end # class NoCache
end # module Waw