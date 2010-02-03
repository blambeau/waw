module Waw
  module Fixtures
  
    # Returns the empty app folder  
    def empty_folder
      File.join(File.dirname(__FILE__), 'fixtures', 'empty')
    end
    
    # Loads and returns the empty application
    def load_empty_app
      @empty_app = Waw.autoload(empty_folder)
      @empty_app.install_living_state({})
    end
    
    # Loads and returns the empty application
    def unload_empty_app
      @empty_app.clean_living_state
      @empty_app.unload
      @empty_app = nil
    end

    # Returns the action app folder  
    def action_folder
      File.join(File.dirname(__FILE__), 'fixtures', 'action')
    end
    
    # Loads and returns the empty application
    def load_action_app
      @action_app = Waw.autoload(action_folder)
      @action_app.install_living_state({})
    end
    
    # Loads and returns the empty application
    def unload_action_app
      @action_app.clean_living_state
      @action_app.unload
      @action_app = nil
    end
    
  end # module Fixtures
end # module Waw