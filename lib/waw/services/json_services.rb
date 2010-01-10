require 'waw/services/json_services_utils'
module Waw
  module Services
    # Helper to create json server services
    class JSONServices
      extend Waw::Services::JSONServices::Utils
      
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
      def install_on_rack_builder(config, builder)
        @mapped.each_pair do |path,controller|
          builder.map path do
            use Waw::RackUtils::JSON
            run controller
          end
        end
      end
      
    end # class JSONServices
  end # module Services
end # module Waw