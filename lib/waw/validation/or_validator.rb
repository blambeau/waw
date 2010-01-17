module Waw
  module Validation
    class OrValidator < Validator
    
      # Empty constructor that overrides the top one
      def initialize(*validators)
        @validators = validators
      end
    
      # Calls the block installed at initialization time    
      def validate(*values)
        @values.all?{|val| @validators.any?{|validator| validator.validate(val)}}
      end
    
      # Converts and validate
      def convert_and_validate(*values)
        converted = []
        values.each do |value|
          found = false
          @validators.each do |validator|
            found, val_converted = validator.convert_and_validate(value)
            if found
              converted << val_converted[0]
              break
            end
          end
          return [false, values] unless found
        end
        [true, converted]
      end
    
    end # class OrValidator
  end # module Validation
end # module Waw
