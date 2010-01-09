module Waw
  module Validation
    class AndValidator < Validator
    
      # Empty constructor that overrides the top one
      def initialize(*validators)
        @validators = validators
      end
    
      # Calls the block installed at initialization time    
      def validate(*values)
        @validators.all?{|validator| validator.validate(*values)}
      end
      alias :=== :validate
    
      # Converts and validate
      def convert_and_validate(*values)
        initials = values
        @validators.each do |validator|
          ok, values = validator.convert_and_validate(*values)
          return [ok, initials] unless ok
        end
        [true, values]
      end
    
    end # class AndValidator
  end # module Validation
end # module Waw
