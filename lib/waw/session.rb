require 'singleton'
module Waw
  class Session
    extend FullState::OnInstance
    
    # Creates a session instance
    def initialize(rack_session)
      @rack_session = rack_session
    end
    
    # Returns Rack's underlying session Hash
    def rack_session
      @rack_session
    end
    
    # Clears the session
    def clear
      rack_session.clear
    end
    
    # Checks if a given key exists in the session
    def has_key?(name)
      rack_session.has_key?(name)
    end
    
    # Returns the value of a given variable
    def [](name)
      rack_session[name]
    end
    alias :get :[]
    
    # Returns the value of a given variable
    def []=(name, value)
      rack_session[name] = value
    end
    alias :set   :[]=
    
    # Resets a given variable whose name is provided
    def reset(name)
      rack_session.delete(name)
    end
    alias :delete :reset
    alias :unset :reset
    
    # Inspects the session
    def inspect
      rack_session.inspect
    end
    
  end
end