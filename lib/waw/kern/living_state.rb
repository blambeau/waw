module Waw
  module Kern
    # Variables that are living during a web request. 
    module LivingState
      
      # The living state object itself
      class Saved
        
        # Rack environment
        attr_reader :rack_env
        
        # Creates a saved instance
        def initialize(rack_env)
          @rack_env = rack_env
        end
        
        # Current request
        def rack_request
          @rack_request ||= Rack::Request.new(rack_env)
        end
        
        # Current response
        def rack_response
          @rack_response ||= Rack::Response.new(rack_env)
        end
        
        # Rack session object
        def rack_session
          @rack_session ||= (rack_env['rack.session'] ||= {})
        end
        
        # Waw session
        def waw_session
          @session ||= ::Waw::Session.new(rack_session)
        end
        
      end # class Saved
      
      # Handler called to install everything required for the living
      # state to work properly, based on a Rack env variable.
      def install_living_state(env)
        stack = (Thread.current[:waw_state] ||= [])
        state = Saved.new(env)
        stack.push(state)
        state
      end
      
      # Cleans the living state when a request is done.
      def clean_living_state
        if (stack = Thread.current[:waw_state])
          stack.pop
        end
      end
      
      # Returns the current waw_state object
      def waw_state
        install_living_state({}) if Thread.current[:waw_state].nil?
        Thread.current[:waw_state].first
      end
      
      # Returns the current Rack env instance
      def rack_env
        waw_state.rack_env
      end
    
      # Returns the current Rack request instance
      def request
        waw_state.rack_request
      end
    
      # Returns the current Rack request instance
      def response
        waw_state.rack_response
      end
    
      # Request parameters
      def params
        request && request.params
      end
    
      # Returns the current Rack session
      def real_session
        waw_state.rack_session
      end
    
      # Returns the waw session decorator
      def session
        waw_state.waw_session
      end
    
    end # module LivingState
  end # module Kern
end # module Waw
module Waw
  module Kern
    # Variables that are living during a web request. 
    module LivingState
      
      # The living state object itself
      class Saved
        
        # Rack environment
        attr_reader :rack_env
        
        # Creates a saved instance
        def initialize(rack_env)
          @rack_env = rack_env
        end
        
        # Current request
        def rack_request
          @rack_request ||= Rack::Request.new(rack_env)
        end
        
        # Current response
        def rack_response
          @rack_response ||= Rack::Response.new(rack_env)
        end
        
        # Rack session object
        def rack_session
          @rack_session ||= (rack_env['rack.session'] ||= {})
        end
        
        # Waw session
        def waw_session
          @session ||= ::Waw::Session.new(rack_session)
        end
        
      end # class Saved
      
      # Handler called to install everything required for the living
      # state to work properly, based on a Rack env variable.
      def install_living_state(env)
        Thread.current[:waw_state] = Saved.new(env)
      end
      
      # Cleans the living state when a request is done.
      def clean_living_state
        Thread.current[:waw_state] = nil
      end
      
      # Returns the current waw_state object
      def waw_state
        Thread.current[:waw_state] ||= Saved.new({})
      end
      
      # Returns the current Rack env instance
      def rack_env
        waw_state.rack_env
      end
    
      # Returns the current Rack request instance
      def request
        waw_state.rack_request
      end
    
      # Returns the current Rack request instance
      def response
        waw_state.rack_response
      end
    
      # Request parameters
      def params
        request && request.params
      end
    
      # Returns the current Rack session
      def real_session
        waw_state.rack_session
      end
    
      # Returns the waw session decorator
      def session
        waw_state.waw_session
      end
    
    end # module LivingState
  end # module Kern
end # module Waw
