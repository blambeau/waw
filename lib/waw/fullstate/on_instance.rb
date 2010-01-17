module Waw
  module FullState
    # Provides the introspection methods for installing fullstate
    # utilities on instances.
    module OnInstance
      
      # Installs a friendly session variable on the controller
      def session_var(name, default_value=nil, &block)
        var = Waw::FullState::Variable.new(name, default_value, &block)
        define_method name do
          var.value(self)
        end
        define_method :"#{name}=" do |arg|
          var.value = arg
        end
      rescue ArgumentError => ex
        raise ex, ex.message, ex.backtrace[1..-1]
      end
      
      # Installs a query variable with a given block
      def query_var(name, &block)
        session_var(name, nil, &block)
      end
      
    end # module OnInstances
  end # module FullState
end # module Waw