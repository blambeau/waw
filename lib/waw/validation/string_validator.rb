module Waw
  module Validation
    class StringValidator < Validator
      
      def validate(*values)
        values.all?{|v| String===v}
      end
      
      def convert_and_validate(*values)
        [validate(*values), values]
      end
      
    end
  end # module Validation
end # module Waw