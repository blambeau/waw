module Waw
  
  # 
  # Defines a specific application controller for executing actions.
  #
  class ActionController < Waw::Controller
  
    # Common utilities about actions  
    module ActionUtils
      
      # Extracts the action name from a given path
      def extract_action_name(path)
        return $1.to_sym if path =~ /([a-zA-Z_]+)$/
        nil
      end
    
      # Checks if an action exists
      def has_action?(name)
        name = extract_action_name(name) unless Symbol===name
        return false unless name
        actions.has_key?(name)
      end
      
      def find_action(name)
        name = extract_action_name(name) unless Symbol===name
        return nil unless name
        actions[name]
      end
      
    end # module ActionUtils
    
    # Class methods
    class << self
      include ActionUtils
      
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
      
      # Installs a routing block for the next action
      def routing(&block)
        @routing = Waw::Routing::ActionRouting.new(&block)
      end
      
      # If a signature has been installed, let the next added method
      # become an action
      def method_added(name)
        if @signature and not(@critical)
          @critical = true
      
          # Create the action instance
          action = Waw::ActionController::Action.new(name, @signature, @routing, instance_method(name))
          actions[name] = action
          
          # Define the secure method
          define_method name do |params|
            action.execute(self, params)
          end 
        end
        @signature, @routing, @critical = nil, nil, false
      end
      
    end # end of class methods
    
    include ActionUtils
    
    def actions
      self.class.actions
    end
    
    # Ensapsules the action call 
    def encapsulate(action, actual_params, &block)
      yield
    end
    
    # Executes the controller
    def execute(env, request, response)
      action_name = request.respond_to?(:path) ? request.path : request[:action]
      Waw.logger.debug("Executing the action whose name is #{action_name}")
      action = find_action(action_name)
      if action
        actual_params = request.params.symbolize_keys
        result = encapsulate(action, actual_params) do 
          action.execute(self, actual_params)
        end
        [:no_bypass, result]
      else
        Waw.logger.warn("Action #{action_name} has not been found")
        [:error, :action_not_found]
      end
    end
  
  end # class ActionController

end # module Waw 