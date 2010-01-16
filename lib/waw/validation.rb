require 'waw/validation/helpers'
require 'waw/validation/validator'
require 'waw/validation/not_validator'
require 'waw/validation/and_validator'
require 'waw/validation/or_validator'

require 'waw/validation/missing_validator'
require 'waw/validation/mandatory_validator'
require 'waw/validation/default_validator'
require 'waw/validation/same_validator'
require 'waw/validation/isin_validator'

require 'waw/validation/boolean_validator'
require 'waw/validation/integer_validator'
require 'waw/validation/float_validator'
require 'waw/validation/regexp_validator'

require 'waw/validation/comparison_validations'
require 'waw/validation/size_validations'
require 'waw/validation/array_validations'
require 'waw/validation/file_validator'
require 'waw/validation/ext'
require 'waw/validation/signature'
module Waw
  #
  # Provides a reusable architecture for parameter validation 
  #
  module Validation
    extend ::Waw::Validation::Helpers
    
    # Validators, by name
    @@validators = {}
    
    
    # Helpers for extensions
    class << self
      
      # Builds a signature with a given block as definition
      def signature(&block)
        Signature.new(&block)
      end

      # Automatically builds the validator and installs a method returning
      # it.
      def validator(name = nil, *args, &block)
        # Build the validator
        validator = args[0]
        if validator.nil? and block
          # first case, block creation
          validator = Validator.new(&block)
        elsif ::Waw::Validation::Validator===validator and block.nil?
          # first case: explicit validator, nothing to do
        elsif ::Class===validator and block.nil?
          # second case: class, for defered creation
        elsif ::Module===validator and block.nil?
          # third case: module of validation rules, nothing to do
        elsif block.nil?
          # fifth case: auto conversion
          validator = to_validator(validator)
        else
          raise WawError, "Invalid Waw::Validation.validator call with #{name}, #{args.inspect}, #{block.inspect}"
        end
        
        # Install it if a name is provided
        return validator if name.nil?
        @@validators[name] = validator

        # Installs the class method that returns the validator
        instance_eval <<-EOF
          class << self
            def #{name}(*args)
              val = @@validators[:#{name}]
              val.is_a?(::Class) ? val.new(*args) : val
            end
          end
        EOF
        
        validator
      end
      
      # User-friendly message for missing validators
      def method_missing(name, *args, &block)
        raise WawError, "Unknown validator #{name}", caller
      end
      
    end # Helpers for extensions
  
    # General validators typically used for parameter validation
    validator :missing,   ::Waw::Validation::MissingValidator.new
    validator :mandatory, ::Waw::Validation::MandatoryValidator.new
    validator :default,   ::Waw::Validation::DefaultValidator
    validator :same,      ::Waw::Validation::SameValidator.new
    validator :equal,     ::Waw::Validation::SameValidator.new
    validator :isin,      ::Waw::Validation::IsInValidator
    
    # Type-based validators
    Integer             = ::Waw::Validation::IntegerValidator.new
    validator :integer,   Integer
    Boolean             = ::Waw::Validation::BooleanValidator.new
    validator :boolean,   Boolean    
    Float               = ::Waw::Validation::FloatValidator.new
    validator :float,     Float
    
    # Regexp-based validators
    validator :mail,      /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]?@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
    validator :weburl,    /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    
    # Validators from other modules
    Array              =  ::Waw::Validation::ArrayValidations
    validator :array,     ::Waw::Validation::ArrayValidations
    validator :size,      ::Waw::Validation::SizeValidations
    validator :is,        ::Waw::Validation::ComparisonValidations
    
    # Validators about files and directories
    validator :directory, validator{|*args| args.all?{|a| ::File.directory?(a)}}
    validator :file,      ::Waw::Validation::FileValidator

  end # module Validation
end # module Waw