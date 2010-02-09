module Waw
  # Provides environment utilities to get the current Rack environment, 
  # session and so on. Some of these utilities make the assumption that 
  # a session is installed in some Rack standard way (through Rack::Session::Pool)
  # for example.
  module EnvironmentUtils
    include Waw::ScopeUtils
    
    DEPRECATED_MSG = <<-EOF
      Method ${method_name} is deprecated and will be removed in version 0.3.
      Please include Waw::ScopeUtils module instead.
    EOF
    
    # Returns the current Rack env instance
    deprecated DEPRECATED_MSG
    def env
      rack_env
    end
    
    # Checks if a session has a given key
    deprecated <<-EOF
      Method ${method_name} is deprecated and will be removed in version 0.3.
      Please include Waw::ScopeUtils module and use session.has_key? instead.
    EOF
    def session_has_key?(key)
      session.has_key?(key)
    end

    # Sets a pair inside the session. Returns the value.
    deprecated <<-EOF
      Method ${method_name} is deprecated and will be removed in version 0.3.
      Please include Waw::ScopeUtils module and use session.set instead.
    EOF
    def session_set(key, value)
      session[key] = value
    end
    
    # Sets a pair inside the session
    deprecated <<-EOF
      Method ${method_name} is deprecated and will be removed in version 0.3.
      Please include Waw::ScopeUtils module and use session.unset instead.
    EOF
    def session_unset(key)
      session.delete(key)
    end
    
    # Get a value from the current session
    deprecated <<-EOF
      Method ${method_name} is deprecated and will be removed in version 0.3.
      Please include Waw::ScopeUtils module and use session.get instead.
    EOF
    def session_get(key)
      session[key]
    end
    
  end # module EnvironmentUtils
end # module Waw