module Waw
  module Validation
    # Checks that arguments belongs to an array of allowed values provided 
    # at construction time.
    class IsInValidator < Validator
      
      # Creates the validator instance
      def initialize(*allowed)
        @allowed = (allowed.size==1 and Range===allowed[0]) ? allowed[0] : allowed
      end
      
      # Validation method
      def validate(*values)
        values.all?{|v| @allowed.include?(v)}
      end
      
      # Convert and validate method
      def convert_and_validate(*values)
        [validate(*values), values]
      end
      
    end # class IsInValidator
  end # module Validation
end # module Waw