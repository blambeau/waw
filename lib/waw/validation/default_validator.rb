module Waw
  module Validation
    class DefaultValidator < Validator
    
      # Creates a validator instance
      def initialize(*args, &block)
        error("Validator default expects one argument or a block: default(19) or default{Time.now} for example", caller)\
          unless (args.size==1 and block.nil?) or (args.empty? and not(block.nil?))
        @which = args.empty? ? :block : :arg
        @default_value = args.empty? ? block : args[0]
      end
    
      # Always returns true
      def validate(*values)
        all_missing?(values)
      end
      
      # Computes the default value from a missing one
      def compute_default(value)
        @which == :block ? @default_value.call(value) : @default_value
      end
    
      # Converts missing values by the default one
      def convert_and_validate(*values)
        validate(*values) ? [true, values.collect{|v| compute_default(v)}] : [false, values]
      end
    
    end # class DefaultValidator
  end # module Validation
end # module Waw
