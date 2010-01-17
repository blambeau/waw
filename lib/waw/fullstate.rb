module Waw
  #
  # Provides utilities to get state on controllers and other tools
  #
  module FullState
    module ClassMethods
      
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
      
    end # module ClassMethods
  end # module FullState
end # module Waw