module Waw
  module ScopeUtils
    
    # Returns the current Rack env instance
    def rack_env
      Thread.current[:rack_env] ||= {}
    end
    
    # Returns the current Rack request instance
    def request
      Thread.current[:rack_request]
    end
    
    # Returns the current Rack request instance
    def response
      Thread.current[:rack_response]
    end
    
    # Request parameters
    def params
      request && request.params
    end
    
    # Returns the current Rack session
    def real_session
      rack_env['rack.session'] ||= {}
    end
    
    # Returns the waw session decorator
    def session
      Waw::Session.instance
    end
    
  end # module ScopeUtils
end # module Waw