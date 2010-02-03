module Waw
  module ScopeUtils
    
    # Find the kernel context whose call must be delegated to.
    def find_kernel_context
      return self.waw_kernel if self.respond_to?(:waw_kernel)
      return Waw.kernel if Waw.kernel
      Waw.logger.warn("Using a empty kernel because no one has been found")
      Waw::Kern::App.new("Empty autoloaded kernel").autoload(File.join(File.dirname(__FILE__), 'kern', 'empty'))
    end
    
    ################################################################# About waw application
    
    # Returns the root folder
    def root_folder
      find_kernel_context.root_folder
    end
    
    # Returns waw resources
    def config
      find_kernel_context.config
    end
    
    # Logger to use
    def logger
      find_kernel_context.logger
    end
    
    # Returns waw resources
    def resources
      find_kernel_context.resources
    end
    
    ################################################################# About current request
    
    # Returns the current Rack env instance
    def rack_env
      find_kernel_context.rack_env
    end
    
    # Returns the current Rack request instance
    def request
      find_kernel_context.request
    end
    
    # Returns the current Rack request instance
    def response
      find_kernel_context.response
    end
    
    # Request parameters
    def params
      find_kernel_context.params
    end
    
    ################################################################# About current session
    
    # Returns the current Rack session
    def real_session
      find_kernel_context.real_session
    end
    
    # Returns the waw session decorator
    def session
      find_kernel_context.session
    end
    
  end # module ScopeUtils
end # module Waw