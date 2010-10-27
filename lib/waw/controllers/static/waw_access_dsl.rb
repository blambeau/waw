module Waw
  class StaticController < ::Waw::Controller
    class WawAccess
      # Domain specific language for .wawaccess language
      class DSL
        include ::Waw::Validation
        
        # Creates a new DSL instance
        def initialize(wawaccess)
          raise ArgumentError, "wawaccess cannot be nil" unless WawAccess===wawaccess
          @wawaccess = wawaccess
          @matchers = {}
        end
        
        # Returns a validator that matches the root of the wawaccess tree
        def root
          Waw::Validation.validator{|served_file| File.expand_path(served_file) == File.expand_path(@wawaccess.root.folder)}
        end
        
        # Installs a matcher
        def matcher(name, &predicate)
          @matchers[name] = Matcher.new(@wawaccess, predicate)
          (class << self; self; end).send(:define_method,name) do
            @matchers[name]
          end
        end
        
        # Starts a wawaccess file
        def wawaccess(&block)
          raise WawError, "#{@wawaccess.identifier}: missing block in wawaccess call" unless block
          self.instance_eval(&block)
        end
        
        # Installs the default strategy
        def strategy(which = :unknown)
          raise WawError, "#{@wawaccess.identifier}: unrecognized wawaccess strategy #{which}" unless [:deny_all, :allow_all].include?(which)
          @wawaccess.strategy = which
        end
        
        # Installs the inherits strategy
        def inherits(which = "unknown")
          raise WawError, "#{@wawaccess.identifier}: unrecognized wawaccess inherits #{which}" unless [true, false].include?(which)
          @wawaccess.inherits = which
        end
        
        # Serve some patterns
        def match(*patterns, &block)
          patterns = patterns.compact
          raise WawError, "#{@wawaccess.identifier}: missing patterns in wawaccess.match call" if patterns.empty?
          raise WawError, "#{@wawaccess.identifier}: missing block in wawaccess.match call" if block.nil?
          @wawaccess.add_serve(patterns, &block)
        end
        
      end
    end # class WawAccess
  end # class StaticController
end # module Waw