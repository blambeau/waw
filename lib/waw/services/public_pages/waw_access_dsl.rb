module Waw
  module Services
    module PublicPages
      class WawAccess
        # Domain specific language for .wawaccess language
        class DSL
          include Waw::Validation
          
          # Creates a new DSL instance
          def initialize(wawaccess)
            raise ArgumentError, "wawaccess cannot be nil" unless WawAccess===wawaccess
            @wawaccess = wawaccess
          end
          
          # Checks some access block
          def self.check_waw_acccess_block(block, wawaccess, name)
            raise WawError, "#{wawaccess.identifier}: #{name} expects a block of arity 0"\
              if (block and (block.arity != -1))
          end
          
          # Starts a wawaccess file
          def wawaccess(&block)
            raise WawError, "#{@wawaccess.identifier}: missing block in wawaccess call" unless block
            self.instance_eval &block
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
            DSL.check_waw_acccess_block(block, @wawaccess, 'serve')
            @wawaccess.add_serve(patterns, &block)
          end
          
        end
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw