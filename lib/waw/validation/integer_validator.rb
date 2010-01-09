module Waw
  module Validation
    class IntegerValidator < Validator
    
      def validate(*values)
        values.all?{|val| ::Integer===val}
      end
      alias :=== :validate
    
      def convert_and_validate(*values)
        ok = values.all?{|v| Integer===v or (/\d+/ =~ v)}
        ok ? [true, values.collect{|v| v.to_s.to_i}] : [false, values]
      end
    
    end # class IntegerValidator
  end # module Validation
end # module Waw
