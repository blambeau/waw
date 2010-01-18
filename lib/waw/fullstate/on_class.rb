module Waw
  module FullState
    # Provides the introspection methods for installing fullstate
    # utilities on classes.
    module OnClass
            
      # Returns the class full state variables
      def __full_state_variables
        @__full_state_variables ||= {}
      end
            
      # Installs a friendly session variable on the controller
      def session_var(name, default_value=nil, &block)
        __full_state_variables[name] = Waw::FullState::Variable.new(name, default_value, &block)
        instance_eval <<-EOF
          class << self
            def #{name}
              __full_state_variables[:#{name}].value(self)
            end
            def #{name}=(arg)
              __full_state_variables[:#{name}].value = arg
            end
            def reset(varname)
              __full_state_variables[varname].reset
            end
          end
        EOF
      end
      
      # Installs a query variable with a given block
      def query_var(name, &block)
        session_var(name, nil, &block)
      end
      
    end # module OnClasses
  end # module FullState
end # module Waw