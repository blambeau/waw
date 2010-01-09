module Waw
  module Validation
    class OrValidator < Validator
    
      # Empty constructor that overrides the top one
      def initialize(*validators)
        @validators = validators
      end
    
      # Calls the block installed at initialization time    
      def validate(*values)
        @validators.any?{|validator| validator.validate(*values)}
      end
      alias :=== :validate
    
      # Converts and validate
      def convert_and_validate(*values)
        @validators.each do |validator|
          ok, new_values = validator.convert_and_validate(*values)
          return [ok, new_values] if ok
        end
        [false, values]
      end
    
    end # class OrValidator
  end # module Validation
end # module Waw
