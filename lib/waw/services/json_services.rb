module Waw
  module Services
    # Helper to create json server services
    class JSONServices
      
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
      
    end # class JSONServices
  end # module Services
end # module Waw