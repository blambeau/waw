module Rack
  class Builder
    
    #
    # Adds or push an error handler on top of the application chain.
    #
    # The method accepts the following argument variants:
    #
    #   error_handler{|k,ex| ... }
    #   error_handler(SomeValidator){|k,ex| ... }
    #   error_handler(SomeHandler)
    #   error_handler(SomeValidator, SomeHandler)
    #
    def error_handler(*args, &block)
      @ins << lambda{|app| 
        if ::Waw::ErrorHandler === app
          app.unshift(*args, &block)
          app
        else
          handler = ::Waw::ErrorHandler.new(app)
          handler.push(*args, &block)
          handler
        end
      }
    end
    
    #
    # The to_app method works as follows:
    #
    #   error_handler(args_1) -> 
    #   error_handler(args_2) -> 
    #   use X  -> lambda{|app| X.new(app)}
    #   use Y  -> lambda{|app| Y.new(app)}
    #   run Z  -> Z
    #
    # which leads to a memo call on the @ins array
    #   Y_instance = lambdaY.call(Z)
    #   X_instance = lambdaX.call(Y_instance)
    #   ...
    #   
    
  end # module Builder
end # module Rack