module Waw
  # Provides environment utilities to get the current Rack environment, 
  # session and so on. Some of these utilities make the assumption that 
  # a session is installed in some Rack standard way (through Rack::Session::Pool)
  # for example.
  module EnvironmentUtils
    
    # Returns the current Rack env instance
    def env
      Thread.current[:rack_env]
    end
    
    # Returns the current Rack request instance
    def request
      Thread.current[:rack_request]
    end
    
    # Returns the current Rack request instance
    def response
      Thread.current[:rack_response]
    end
    
    # Returns the current Rack session
    def session
      env['rack.session']
    end
    
    # Checks if a session has a given key
    def session_has_key?(key)
      session_get(key)
    end

    # Sets a pair inside the session. Returns the value.
    def session_set(key, value)
      session[key] = value
    end
    
    # Sets a pair inside the session
    def session_unset(key)
      session.delete(key)
    end
    
    # Get a value from the current session
    def session_get(key)
      session[key]
    end
    
  end # module EnvironmentUtils
end # module Waw