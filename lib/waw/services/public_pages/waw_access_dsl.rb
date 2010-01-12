module Waw
  module Services
    module PublicPages
      class WawAccess
        # Domain specific language for .wawaccess language
        class DSL
          include Waw::Validation
          
          # Creates a new DSL instance
          def initialize(wawaccess, file="unknown_file")
            @wawaccess = wawaccess
            @file = file
          end
          
          # Checks some access block
          def self.check_waw_acccess_block(block, name)
            raise WawError, "#{@file}: #{name} expects a block of arity 3 (url, pagefile, app)"\
              if (block and (block.arity != 3))
          end
          
          # Starts a wawaccess file
          def wawaccess(&block)
            raise WawError, "#{@file}: missing block in wawaccess call" unless block
            self.instance_eval &block
          end
          
          # Installs the default strategy
          def strategy(which = :unknown)
            raise WawError, "#{@file}: unrecognized wawaccess strategy #{which}" unless [:deny_all, :allow_all].include?(which)
            @wawaccess.strategy = which
          end
          
          # Installs the inherits strategy
          def inherits(which = "unknown")
            raise WawError, "#{@file}: unrecognized wawaccess inherits #{which}" unless [true, false].include?(which)
            @wawaccess.inherits = which
          end
          
          # Serve some patterns
          def serve(*patterns, &block)
            raise WawError, "#{@file}: missing patterns in wawaccess.serve call" if patterns.empty?
            DSL.check_waw_acccess_block(block, 'serve')
            @wawaccess.add_serve(patterns, &block)
          end
          
          # Installs a find not found handler
          def notfound(&block)
            DSL.check_waw_acccess_block(block, 'notfound')
            @wawaccess.notfound = block
          end
          
        end
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw