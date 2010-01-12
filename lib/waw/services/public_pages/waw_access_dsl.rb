module Waw
  module Services
    module PublicPages
      class WawAccess
        # Domain specific language for .wawaccess language
        class DSL
          
          # Creates a new DSL instance
          def initialize(wawaccess, file="unknown_file")
            @wawaccess = wawaccess
            @file = file
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
          
          # Serve some patterns
          def serve(*patterns, &block)
            raise WawError, "#{@file}: missing patterns in wawaccess.serve call" if patterns.empty?
            raise WawError, "#{@file}: wawaccess.serve expects a block of arity 3 (url, pagefile, app)"\
              if (block and (block.arity != 3))
            @wawaccess.serve(patterns, &block)
          end
          
        end
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw