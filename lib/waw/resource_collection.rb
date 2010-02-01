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
      def method_missing(name, *args, &block)
        if args.length==0 and block.nil?
          @resources.send(name)
        elsif args.length==1 and block.nil?
          @resources.send(:add_resource, name, args[0])
        elsif args.length==0 and block
          @resources.send(:add_resource, name, nil, &block)
        elsif block
          raise ArgumentError, "Bad resources usage on #{name} #{args.inspect} #{block.inspect}"
        end
      end
      
    end # class Resources
    
    # Resource name
    attr_reader :__name
    
    # Creates a resource collection
    def initialize(name = "unnamed")
      @resources = {}
      @__name = name
    end
    
    # Yields the block with each resource key,value pair
    def each
      @resources.each_pair {|k, v| yield(k, v)}
    end
    alias :each_pair :each
    
    # Returns the resource installed under name
    def [](name)
      @resources[name]
    end
    
    # Checks if a resource exists
    def has_resource?(name)
      @resources.has_key?(name)
    end
    
    # Add a resource
    def add_resource(name, value, &block)
      if not(value.nil?) and block.nil?
        @resources[name.to_s.to_sym] = value
        self.instance_eval <<-EOF
          def #{name}
            @resources[:#{name}] 
          end
        EOF
      elsif value.nil? and not(block.nil?)
        @resources[name.to_s.to_sym] = block
        self.instance_eval <<-EOF
          def #{name}
            @resources[:#{name}].call(self)
          end
        EOF
      else
        raise ArgumentError, "ResourceCollection.add_resource expects one argument or a block"
      end
    end
    
    # Logs a friendly message and returns nil
    def method_missing(name, *args)
      if args.size==1
        args[0]
      elsif args.size==0
        Waw.logger.warn("No such resource #{name} on #{@__name}, (#{caller[0]})")
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