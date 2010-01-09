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
        @resources.send(:add_resource, name, args[0])
      end
      
    end # class Resources
    
    # Creates a resource collection
    def initialize(name = "unnamed")
      @resources = {}
      @name = name
    end
    
    # Yields the block with each resource key,value pair
    def each
      @resources.each_pair {|k, v| yield(k, v)}
    end
    
    # Returns the resource installed under name
    def [](name)
      @resources[name]
    end
    
    # Checks if a resource exists
    def has_resource?(name)
      @resources.has_key?(name)
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
    
    # Logs a friendly message and returns nil
    def method_missing(name, *args)
      if args.size==1
        args[0]
      elsif args.size==0
        Waw.logger.warn("No such resource #{name} on #{@name}, (#{caller[0]})")
        nil
      else
        super
      end
    end
    
    # Parses some resource string
    def self.parse_resources(str, name = "unnamed")
      r = ResourceCollection.new(name)
      DSL.new(r).instance_eval str
      r
    end
    
    # Parses a resource file
    def self.parse_resource_file(f, name=File.basename(f, '.rs'))
      parse_resources File.read(f), name
    end
    
    private :add_resource
  end # class ResourceCollection
end # module Waw