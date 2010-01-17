module Waw
  module FullState
    # Provides the introspection methods for installing fullstate
    # utilities on instances.
    module OnInstance
      
      # Installs a friendly session variable on the controller
      def session_var(name, default_value=nil, &block)
        # define the getter first
        define_method name do
          if Waw.session_has_key?(name)
            Waw.session_get(name)
          elsif block
            block.call
          else
            default_value
          end
        end
        
        # define the setter now
        define_method :"#{name}=" do |arg|
          Waw.session_set(name, arg)
        end
      end
      
    end # module OnInstances
  end # module FullState
end # module Waw