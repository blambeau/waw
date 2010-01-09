module Waw
  # Localized resources
  class ResourceCollection
    
    # DSL for resources
    class DSL
      
      # Creates a DSL instance
      def initialize(resources)
        @resources = resources
      end
      
      # Adds a resource to the collection
      def method_missing(name, *args)
        @resources.add_resource(name, args[0])
      end
      
    end # class Resources
    
    # Creates a resource collection
    def initialize
      @resources = {}
    end
    
    # Add a resource
    def add_resource(name, value)
      @resources[name.to_s.to_sym] = value
      self.instance_eval <<-EOF
        def #{name}
          @resources[:#{name}]
        end
      EOF
    end
    
    # Parses some resource string
    def self.parse_resources(str)
      r = ResourceCollection.new
      DSL.new(r).instance_eval str
      r
    end
    
    # Parses a resource file
    def self.parse_resource_file(f)
      parse_resources File.read(f)
    end
    
  end # class ResourceCollection
end # module Waw