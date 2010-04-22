require 'waw/validation/errors'
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

require 'date'
require 'waw/validation/boolean_validator'
require 'waw/validation/string_validator'
require 'waw/validation/integer_validator'
require 'waw/validation/float_validator'
require 'waw/validation/date_validator'
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
    
    # Ruby classes => validators
    @@ruby_classes_to_validators = {}
    
    # Other modules that include me
    @@who_includes_me = []
    
    # Allows this module to be included as a normal one, hiding
    # introspection mechanisms to install validators
    class << self
      
      # When this module is included in _who_ we install all validation
      # methods dynamically
      def included(who)
        @@who_includes_me << who unless @@who_includes_me.include?(who)
        @@validators.each_pair do |name, validator|
          who.module_eval <<-EOF
            def #{name}(*args, &block)
              ::Waw::Validation.send(:#{name}, *args, &block)
            end
          EOF
        end
      end
      
    end # Metaprogramming hack for module inclusion
    
    
    # Helpers for extensions
    class << self
      
      # Builds a signature with a given block as definition
      def signature(&block)
        Signature.new(&block)
      end
      
      # Adds a ruby class => validator mapping
      def ruby_class_to_validator(ruby_class, validator)
        @@ruby_classes_to_validators[ruby_class] = validator
      end
      
      # Returns a validator to use for a given ruby class
      def validator_for_ruby_class(ruby_class, raise_if_not_found=true)
        val = @@ruby_classes_to_validators[ruby_class]
        return val unless val.nil?
        raise "Unable to find a validator for #{ruby_class}" if raise_if_not_found
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
        elsif validator.is_a?(::Class) and block.nil?
          # second case: class, for defered creation
          validator = to_validator(validator) unless validator.ancestors.include?(::Waw::Validation::Validator)
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
            def #{name}(*args, &block)
              val = @@validators[:#{name}]
              val.is_a?(::Class) ? val.new(*args, &block) : val
            end
          end
        EOF
        
        # Install the class methods on all modules that include me
        @@who_includes_me.each do |mod|
          mod.module_eval <<-EOF
            def #{name}(*args, &block)
              ::Waw::Validation.send(:#{name}, *args, &block)
            end
          EOF
        end
        
        validator
      end
      
      # User-friendly message for missing validators
      def method_missing(name, *args, &block)
        raise WawError, "Unknown validator #{name}", caller
      end
      
    end # Helpers for extensions
  
    # General validators typically used for parameter validation
    validator :always_accept, validator{|*args| true}
    validator :missing,   ::Waw::Validation::MissingValidator.new
    validator :mandatory, ::Waw::Validation::MandatoryValidator.new
    validator :default,   ::Waw::Validation::DefaultValidator
    validator :same,      ::Waw::Validation::SameValidator.new
    validator :equal,     ::Waw::Validation::SameValidator.new
    validator :isin,      ::Waw::Validation::IsInValidator
    
    # Type-based validators
    validator :boolean,   ::Waw::Validation::BooleanValidator.new    
    validator :string,    ::Waw::Validation::StringValidator.new
    validator :integer,   ::Waw::Validation::IntegerValidator.new
    validator :float,     ::Waw::Validation::FloatValidator.new
    validator :date,      ::Waw::Validation::DateValidator.new
    ruby_class_to_validator(::Boolean, boolean)
    ruby_class_to_validator(::String, string)
    ruby_class_to_validator(::Integer, integer)
    ruby_class_to_validator(::Float, float)
    ruby_class_to_validator(::Date, date)
    
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