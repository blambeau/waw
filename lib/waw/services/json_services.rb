module Waw
  module Services
    # Helper to create json server services
    class JSONServices
      
      attr_reader :mapped
      
      # Creates a service instance with action controllers mapped
      # to given URLs
      def initialize(mapped)
        raise ArgumentError, "JSONServices expects a hash of path => Waw::ActionController, #{mapped.inspect} received" unless check_mapped(mapped)
        @mapped = mapped
      end
      
      # Checks a mapped hash
      def check_mapped(mapped)
        Hash===mapped and mapped.all? do |path, c|
          String===path and Waw::ActionController===c
        end
      end
      
      # Service installation on a rack builder
      def factor_service_map(config, map)
        @mapped.each_pair do |path,controller|
          map[path] = Waw::RackUtils::JSON.new(controller)
        end
        map
      end
      
      # Looks for an action
      def method_missing(name, *args, &block)
        if name.to_s =~ /[a-z_]+/ and args.length==0
          @mapped.each_value do |controller|
            return controller.find_action(name) if controller.has_action?(name)
          end
          Waw.logger.warn("Unable to find action #{name} on JSONServices")
          nil
        else
          super(name, *args, &block)
        end
      end
      
    end # class JSONServices
  end # module Services
end # module Waw