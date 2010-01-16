module Waw
  module Validation
    #
    # A service or data signature, as a list of validations to be respected.
    #
    class Signature
    
      # The DSL attached to signature
      class DSL
      
        # Creates a DSL instance
        def initialize(signature)
          @signature = signature
        end
      
        # Adds a validation
        def validation(args, validator, onfailure)
          @signature.add_validation(args, validator, onfailure)
        end
      
        # When a methos is missing
        def method_missing(name, *args, &block)
          Waw::Validation.send(name, *args, &block)
        rescue Exception => ex
          raise ex.class, ex.message, caller
        end
      
      end # class DSL
    
      # A validation rule
      class ValidationRule
      
        # Creates a Validation instance
        def initialize(args, validator, onfailure)
          @args = args
          @validator = validator
          @onfailure = onfailure
        end
      
        # Validates argument values given through a hash
        def validate(hash)
          ok = @validator.validate(*@args.collect{|arg| hash[arg]})
          ok ? nil : @onfailure
        end
      
        # Converts and validate values given trough a hash
        def convert_and_validate(hash)
          ok, values = @validator.convert_and_validate(*@args.collect{|arg| hash[arg]})
          @args.each_with_index {|arg, i| hash[arg] = values[i]} if ok
          ok ? nil : @onfailure
        end
      
      end # class Validation
    
      # Rules
      attr_accessor :rules
    
      # Creates an empty signature
      def initialize(&block)
        @rules = []
        DSL.new(self).instance_eval(&block) unless block.nil?
      end
    
      # Merges this signature with additional definition
      def merge(&block)
        signature = self.dup
        DSL.new(signature).instance_eval(&block) unless block.nil?
        signature
      end
    
      # Adds a validation rule
      def add_validation(args, validator, onfailure)
        args = [args] if Symbol===args
        @rules << ValidationRule.new(args, validator, onfailure)
      end
    
      # Validates argument values given through a hash and returns a series
      # of onfailure flags.
      def validate(hash)
        converted, failures = hash.dup, []
        failures = @rules.collect{|rule| rule.validate(converted)}.compact
        failures.empty? ? [true, converted] : [false, failures]
      end
    
      # Validates argument values given through a hash and returns a series
      # of onfailure flags.
      def apply(hash)
        converted, failures = hash.dup, []
        failures = @rules.collect{|rule| rule.convert_and_validate(converted)}.compact
        failures.empty? ? [true, converted] : [false, failures]
      end
      
      # Checks if the signature allows passing with some values 
      def allows?(hash)
        apply(hash)[0]
      end
      
      # Checks if the signature blocks with some values 
      def blocks?(hash)
        not(allows?(hash))
      end
    
      # Duplicates this validation
      def dup
        copy = Signature.new
        copy.rules = self.rules.dup
        copy
      end
    
      protected :rules=
    end # class Signature
  end # module Validation
end # module Waw
