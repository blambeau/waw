module Waw
  
  # 
  # Defines a specific application controller for executing actions.
  #
  class ActionController < Waw::Controller
    
    # Class methods
    class << self
      
      # Returns the actions
      def actions
        @actions ||= {}
      end
      
      # Fired when a signature will be next installed
      def signature(signature=nil, &block)
        signature = (signature.nil? ? Waw::Validation::Signature.new : signature)
        signature = signature.merge(&block) if block
        @signature = signature
      end
      
      # If a signature has been installed, let the next added method
      # become an action
      def method_added(name)
        if @signature and not(@critical)
          @critical = true                      # next method will be added by myself
      
          # Create the action instance
          action = Waw::ActionController::Action.new(name, @signature, instance_method(name))
          actions[name] = action
          
          # Define the secure method
          define_method name do |params|
            action.execute(self, params)
          end 
        end
        @signature, @critical = nil, false       # erase signature, leave critical section
      end
      
    end # end of class methods
    
    # Ensapsules the action call 
    def encapsulate(action, actual_params, &block)
      yield
    end
    
    # Executes the controller
    def execute(env, request, response)
      action_name = request.respond_to?(:path) ? request.path : request[:action]
      Waw.logger.debug("Executing the action whose name is #{action_name}")
      result = if action_name =~ /([a-zA-Z_]+)$/
        action = $1.to_sym 
        if self.respond_to?(action) 
          actual_params = request.params.symbolize_keys
          encapsulate(action, actual_params) do 
            self.send(action, actual_params)
          end
        else
          Waw.logger.warn("Action #{action_name} has not been found (no matching method)")
          [:error, :action_not_found]
        end
      else
        Waw.logger.warn("Action #{action_name} has not been found")
        [:error, :action_not_found]
      end
      [:no_bypass, result]
    end
  
  end # class ActionController

end # module Waw 