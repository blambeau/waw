require 'waw/controllers/action/action_utils'
require 'waw/controllers/action/action'
require 'waw/controllers/action/js_generation'
module Waw
  
  # 
  # Defines a specific application controller for executing actions.
  #
  class ActionController < Waw::Controller
    include ActionUtils
    
    class << self
      # When this class is inherited, it becomes a Singleton
      def inherited(child)
        child.instance_eval { include Singleton }
      end
    end
    
    class << self
      include ActionUtils
      
      # Returns installed actions
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
    
    # Returns the actions installed on this controller
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
        [200, {}, result]
      else
        Waw.logger.warn("Action #{action_name} has not been found")
        [200, {}, [:error, :action_not_found]]
      end
    end
  
  end # class ActionController

end # module Waw 