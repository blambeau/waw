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
    alias :get   :[]
    
    # Returns the value of a given variable
    def []=(name, value)
      Waw.real_session[name] = value
    end
    alias :set   :[]=
    
    # Resets a given variable whose name is provided
    def reset(name)
      Waw.real_session.delete(name)
    end
    alias :delete :reset
    alias :unset :reset
    
    # Saves the state of someone
    def save_state(who, state)
      save_id = if who.respond_to?(:waw_id)
        who.waw_id.to_s
      else
        Waw.logger.warn("Object #{who} (#{who.class}) does not have a waw_id, using object_id instead (which is unsafe)")
        who.object_id
      end
      self[save_id] = state
    end
    
    # Restores the state of someone
    def restore_state(who, default = nil)
      save_id = if who.respond_to?(:waw_id)
        who.waw_id.to_s
      else
        Waw.logger.warn("Object #{who} (#{who.class}) does not have a waw_id, using object_id instead (which is unsafe)")
        who.object_id
      end
      self[save_id] || default
    end
    
  end
end