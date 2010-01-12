module Waw
  module Services
    module PublicPages
      # Waw version of .htaccess files
      class WawAccess
        
        # Strategy :allow_all or :deny_all
        attr_accessor :strategy
        
        # The parent wawaccess file
        attr_accessor :parent
        
        # Creates a default WawAccess file
        def initialize(read_file=nil)
          @strategy = :allow_all
          @serve = {}
          dsl_merge_file(read_file) if read_file
        end
        
        ################################################### About installation through DSL
        
        # Installs some pattern services
        def serve(patterns, &block)
          block = Kernel.lambda{|url, pagefile, app| Hash.new } unless block
          patterns.each do |pattern|
            @serve[pattern] = block
          end
        end
        
        # Merges a DSL string inside this waw access
        def dsl_merge(dsl_str, read_file=nil)
          begin
            WawAccess::DSL.new(self, read_file).instance_eval(dsl_str)
          rescue WawError => ex
            raise ex
          rescue Exception => ex
            raise WawError, "Corrupted .wawaccess file #{read_file}: #{ex.message}", ex.backtrace
          end
          self
        end
        
        # Merge with a .wawaccess file
        def dsl_merge_file(read_file)
          raise WawError, "Missing .wawaccess file #{readfile}" unless File.file?(read_file)
          dsl_merge(File.read(read_file), read_file)
          self
        end
        
        ################################################### About wawaccess itself
        
        # Finds the block used for serving a given file
        def find_prepare_block(file, use_hierarchy = true)
          ext = File.extname(file)
          if @serve.has_key?(ext)
            @serve[ext]
          elsif use_hierarchy and parent
            parent.find_prepare_block(file, true)
          else
            nil
          end
        end
        
        # Checks if this wawaccess file allows serving a given file
        def may_serve?(file, use_hierarchy = true)
          not(find_prepare_block(file).nil?)
        end
        
        # Prepare the context for instantiating a given file
        def prepare_context(url, file, app)
          (block = find_prepare_block(file)) and block.call(url, file, app)
        end
        
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw