module Waw
  module Validation
    class FloatValidator < ::Waw::Validation::Validator
      
      # Regular expression we use
      FLOAT_REGEXP = /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
      
      def validate(*values)
        values.all?{|v| ::Float===v}
      end
      
      def convert_and_validate(*values)
        ok = values.all?{|v| FLOAT_REGEXP =~ v.to_s}
        ok ? [true, values.collect{|v| v.to_s.to_f}] : [false, values]
      end
      
    end
  end # module Validation
end # module Waw