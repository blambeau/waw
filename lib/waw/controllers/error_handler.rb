require 'waw/controllers/error/backtrace'
module Waw
  class ErrorHandler < ::Waw::Controller
    
    # Creates an error handler rack application
    def initialize(app, *handlers)
      @app = app
      @handlers = handlers
    end
    
    # Adds an error handler as a block. 
    def add_handler(handler, &block)
      raise ArgumentError, "Unable to install both handler" if (handler && block)
      raise ArgumentError, "Missing block as error handler" unless (handler || block)
      @handlers << (handler || block)
    end
    
    # Checks if a result seems a valid rack application result
    def seems_valid_result?(result)
      not(result.nil?) and Array===result and result.size==3
    end
    
    # Handles a call
    def call(env)
      @app.call(env)
    rescue Exception => ex
      kernel = find_kernel_context
      @handlers.each do |handler|
        result = handler.call(kernel, ex)
        return result if seems_valid_result?(result)
      end
      raise ex
    end
    
  end # class ErrorHandler
end # module Waw