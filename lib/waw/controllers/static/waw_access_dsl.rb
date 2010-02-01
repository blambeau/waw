module Waw
  class StaticController < ::Waw::Controller
    class WawAccess
      # Domain specific language for .wawaccess language
      class DSL
        #include ::Waw::Validation
        
        # Creates a new DSL instance
        def initialize(wawaccess)
          raise ArgumentError, "wawaccess cannot be nil" unless WawAccess===wawaccess
          @wawaccess = wawaccess
        end
        
        def file(opts = {})
          Waw::Validation.file(opts)
        end
        
        def directory
          Waw::Validation.directory
        end
        
        def root
          Waw::Validation.validator{|served_file| File.expand_path(served_file) == File.expand_path(@wawaccess.root.folder)}
        end
        
        # We delegate everything to Waw::Validation
        def method_missing(name, *args, &block)
          Waw::Validation.send(name, *args, &block)
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
          raise WawError, "#{@wawaccess.identifier}: missing patterns in wawaccess.serve call" if patterns.empty?
          @wawaccess.add_serve(patterns, &block)
        end
        
      end
    end # class WawAccess
  end # class StaticController
end # module Waw