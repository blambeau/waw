module Waw
  module WSpec
    module HTMLAnalysis
      
      # A tag helper class
      class Tag

        # Result of the regexp matching applied to get this tag
        attr_reader :match
        
        # Name of the tag
        attr_reader :name
        
        # Tag attributes
        attr_reader :attributes
        
        # Creates a Tag instance
        def initialize(match, name, attributes)
          @match, @name, @attributes = match, name, attributes
        end
        
        # Returns the value of an attribute
        def [](key)
          attributes[key]
        end
        
        # Checks if this tags has a given attribute
        def has_attribute?(name)
          attributes.has_key?(name)
        end
        
        # Checks if this tag matches a given attributes specification
        def matches?(opts = {})
          return true if (opts.nil? or opts.empty?)
          opts.each_pair do |name, value|
            return false unless self.has_attribute?(name)
            case value
              when Regexp
                return false unless value =~ self[name]
              else
                return false unless value.to_s == self[name]
            end
          end
          true
        end
        
      end # class Tag

    end # module HTMLAnalysis
  end # module WSpec
end # module Waw