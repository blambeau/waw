module Waw
  module Validation
    class FileValidator < Validator
    
      def initialize(opts = {})
        @options = opts
      end
      
      # Seems a valid file
      def seems_a_file?(f)
        return false unless File.file?(f)
        return true unless @options
        @options.each_pair do |key, value|
          case key
            when :extension
              return false unless value==File.extname(f)
            else
              raise Waw::Error, "Unexpected FileValidator option #{key} : #{value}"
          end
        end
        true
      end
    
      def validate(*values)
        values.all?{|f| seems_a_file?(f)}
      end
    
    end # class NotValidator
  end # module Validation
end # module Waw
