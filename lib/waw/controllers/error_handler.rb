require 'waw/controllers/error/backtrace'
module Waw
  class ErrorHandler < ::Waw::Controller
    
    # Creates an error handler rack application
    def initialize(app)
      @app = app
      @validators, @handlers = [], []
    end
    
    # Handles arguments of push and unshift
    def handle_args(args, &block)
      validator, handler = args
      handler = block if handler.nil?
      validator, handler = nil, validator if handler.nil?
      [validator, handler]
    end
    
    # Adds an error handler. The method accepts the following 
    # argument variants:
    #
    #   add_error_handler{|k,ex| ... }
    #   add_error_handler(SomeValidator){|k,ex| ... }
    #   add_error_handler(SomeHandler)
    #   add_error_handler(SomeValidator, SomeHandler)
    #
    def add_error_handler(*args, &block)
      validator, handler = handle_args(args, &block)
      @validators << validator
      @handlers << handler
    end
    alias :push :add_error_handler 
    
    # Same as add_error_handler but adds it at the begining of the 
    # chain
    def unshift(*args, &block)
      validator, handler = handle_args(args, &block)
      @validators.unshift(validator)
      @handlers.unshift(handler)
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
      @validators.each_with_index do |validator, i|
        if (validator.nil? or (validator===ex))
          result = @handlers[i].call(kernel, ex)
          return result if seems_valid_result?(result)
        end
      end
      raise ex
    end
    
  end # class ErrorHandler
end # module Waw