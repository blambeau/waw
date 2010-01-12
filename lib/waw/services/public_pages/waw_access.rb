module Waw
  module Services
    module PublicPages
      # Waw version of .htaccess files
      class WawAccess
        
        # Strategy :allow_all or :deny_all
        attr_accessor :strategy
        
        # Creates a default WawAccess file
        def initialize(read_file=nil)
          @strategy = :allow_all
          @serve = {}
          if read_file
            begin
              contents = File.read(read_file)
              WawAccess::DSL.new(self, read_file).instance_eval(contents)
            rescue WawError => ex
              raise ex
            rescue Exception => ex
              raise WawError, "Corrupted .wawaccess file #{read_file}: #{ex.message}", ex.backtrace
            end
          end
        end
        
        # Installs some pattern services
        def serve(patterns, &block)
        end
        
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw