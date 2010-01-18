require 'singleton'
module Waw
  class Session
    include Singleton
    extend FullState::OnInstance
    
    # Clears the session
    def clear
      Waw.real_session.clear
    end
    
    # Checks if a given key exists in the session
    def has_key?(name)
      Waw.real_session.has_key?(name)
    end
    
    # Returns the value of a given variable
    def [](name)
      Waw.real_session[name]
    end
    
    # Returns the value of a given variable
    def []=(name, value)
      Waw.real_session[name] = value
    end
    
    # Resets a given variable whose name is provided
    def reset(name)
      Waw.real_session.delete(name)
    end
    alias :delete :reset
    
  end
end