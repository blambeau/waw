module Waw
  module Validation
    # Validator that checks that values match a given regular expression
    class RegexpValidator < ::Waw::Validation::Validator
      
      #
      # Creates a validator instance.
      #
      # If strip is set to true, the regexp is checked against a stripped
      # version of value.to_s. In this case, the conversion strips the string 
      # as well.
      #
      def initialize(regexp, strip = true)
        @regexp, @strip = regexp, strip
      end
      
      # Validation method
      def validate(*values)
        values.all?{|v| @regexp =~ (@strip ? v.to_s.strip : v.to_s)}
      end
      
      # Converts and validate method
      def convert_and_validate(*values)
        validate(*values) ? [true, values.collect{|v| @strip ? v.to_s.strip : v}] : [false, values]
      end
      
    end
  end # module Validation
end # module Waw