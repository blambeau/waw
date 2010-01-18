module Waw
  class Restart
    include Rack::FindRackAppDelegator
    
    # Default options
    DEFAULT_OPTIONS = { :when => :always }
    
    # Creates a restarter instance
    def initialize(app, opts = {}, lock = Mutex.new)
      @options = DEFAULT_OPTIONS.merge(opts)
      @app = app
      @lock = lock
    end
    
    # Should I need to restart?
    def restart?
      @options[:when] == :always
    end
    
    # Handle the call
    def call(env)
      if restart?
        @lock.synchronize do
          root_folder = Waw.root_folder
          Waw.reload
        end
      end
      @app.call(env)
    end
    
  end # class Restart
end # module Waw