module Waw
  module Validation
    class FileValidator < Validator
    
      def initialize(opts = {})
        @options = opts
      end
      
      # Seems a valid file
      def seems_a_file?(f)
        return false unless File.file?(f)
        @options.each_pair do |key, value|
          case key
            when :extension
              return false unless value==File.extname(f)
            else
              Waw.logger.warn("Unexpected FileValidator option #{key} : #{value}")
          end
        end
      end
    
      def validate(*values)
        values.all?{|f| seems_a_file?(f)}
      end
      alias :=== :validate
    
    end # class NotValidator
  end # module Validation
end # module Waw
