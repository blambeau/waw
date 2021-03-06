require 'waw/controllers/action/action_utils'
require 'waw/controllers/action/action'
require 'waw/controllers/action/js_generation'
module Waw
  
  # 
  # Defines a specific application controller for executing actions.
  #
  class ActionController < Waw::Controller
    include ActionUtils
    extend FullState::OnClass
    extend FullState::OnInstance
    
    # All subclasses
    @@controllers = []
    
    class << self

      # Returns known controllers
      def controllers
        @@controllers
      end
        
      # When this class is inherited we track the new controller, it becomes a 
      # Singleton and we install code generation as start hook if not already done.
      def inherited(child)
        super(child)
        # Adds the controller as a child
        controllers << child
        
        # Let it become a singleton
        child.instance_eval { include Singleton }
        
        # And install start hook for code generation
        if controllers.size==1 && (k = Waw.kernel)
          k.add_start_hook(JSGeneration.new) 
          k.add_unload_hook ::Kernel.lambda { @@controllers = [] }
        end
      end

    end

    # This is all about actions 
    class << self
      include ActionUtils
      
      # Returns the url on which this controller is mapped
      def url
        self.instance.url
      end
    
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
          meth = instance_method(name)
          if meth.arity != 1
            raise WawError, "Action #{self}::#{name} is missing its 'params' argument"
          else
            action = Waw::ActionController::Action.new(name, @signature, @routing, self, meth)
            actions[name] = action
          end
          
          # Installs the class method that returns the action
          instance_eval <<-EOF
            class << self
              def #{name}
                actions[:#{name}]
              end
            end
          EOF
          
          # Installs the instance method that execute the action
          define_method name do |params|
            action.execute(params)
          end 
        end
        @signature, @routing, @critical = nil, nil, false
      end
      
    end # end of class methods
    
    # Returns the url on which this controller is mapped
    def url
      find_kernel_context.find_url_of(self)
    end
    
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
      logger.debug("Executing the action whose name is #{action_name}")
      action = find_action(action_name)
      if action
        actual_params = request.params.symbolize_keys
        result = encapsulate(action, actual_params) do 
          action.execute(actual_params)
        end
        logger.debug("ActionResult is #{result.inspect}")
        [200, {}, result]
      else
        logger.warn("Action #{action_name} has not been found")
        [200, {}, [:error, :action_not_found]]
      end
    end
  
  end # class ActionController

end # module Waw 