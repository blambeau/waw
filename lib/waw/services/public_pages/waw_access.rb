module Waw
  module Services
    module PublicPages
      # Waw version of .htaccess files
      class WawAccess
        
        # The folder which is served
        attr_accessor :folder
        
        # Strategy :allow_all or :deny_all
        attr_accessor :strategy
        
        # Does it inherits its parent configuration?
        attr_accessor :inherits
        
        # Handler when the file cannot be found
        attr_accessor :notfound
        
        # The parent wawaccess file
        attr_accessor :parent
        
        # Creates a default WawAccess file
        def initialize(read_file=nil)
          @strategy = :deny_all
          @inherits = true
          @serve = []
          @children = {}
          @read_file = read_file
          dsl_merge_file(read_file) if read_file
        end
        
        ################################################### About installation through DSL
        
        # Returns a wawaccess tree for a given folder
        def self.load_hierarchy(root_folder, parent = nil)
          raise ArgumentError, "Invalid folder #{root_folder}" unless File.directory?(root_folder)

          # Locate and load the .wawaccess file or provide a default one
          wawaccess_file = File.join(root_folder, '.wawaccess')
          if File.exists?(wawaccess_file)
            wawaccess = WawAccess.new(wawaccess_file)
          else
            wawaccess = WawAccess.new
            wawaccess.strategy = :deny_all
            wawaccess.inherits = true
          end
          
          # Set its parent
          wawaccess.folder = File.expand_path(root_folder)
          wawaccess.parent = parent
          
          # Install its children
          Dir.new(root_folder).each do |file|
            next if ['.', '..'].include?(file)
            child_folder = File.join(root_folder, file)
            next unless File.directory?(child_folder)
            
            # Load the child and save it
            wawaccess.add_child(file, WawAccess.load_hierarchy(child_folder, wawaccess))
          end
          wawaccess
        end
        
        ################################################### About installation through DSL
        
        # Adds a child in the hierarchy
        def add_child(folder, wawaccess)
          @children[folder] = wawaccess
        end
        
        # Installs some pattern services
        def add_serve(patterns, &block)
          block = Kernel.lambda{|url, pagefile, app| app.static(pagefile) } unless block
          patterns.each do |pattern|
            @serve << [pattern, block]
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
        
        ################################################### Utilites about paths
        
        # Returns the real path of a file
        def realpath(file)
          File.join(@folder, file)
        end
        
        ################################################### Handlers provided for the user
        
        # Finds the wawaccess for a given path
        def delegate(path)
          return delegate(path.split('/')) if String===path
          return self if path.empty?
          mine = path.shift
          raise WawError, "No .wawaccess found" unless @children[mine]
          @children[mine].delegate(path)
        end
        
        # Serves a static page
        def static(page)
          [200, {'Content-Type' => 'text/plain'}, [page]]
        end
        
        ################################################### About wawaccess itself
        
        # Finds the block used for serving a given file
        def find_serve_block(file, use_hierarchy = true)
          ext = File.extname(file)
          @serve.each do |pattern, block|
            case pattern
              when '*'
                return block
              when /^\*?\.[a-z]+$/
                # file extension
                return block if File.extname(file)==pattern
              when Regexp
                # regular expression
                return block if pattern =~ file
              when Waw::Validation::Validator
                # a waw validator
                return block if pattern.validate(file)
              else
                raise WawError, "Unrecognized wawaccess pattern #{pattern}"
            end
          end
          (use_hierarchy and @parent) ? parent.find_serve_block(file, true) : nil
        end
        
        # Checks if this wawaccess file allows serving a given file
        def may_serve?(file, use_hierarchy = true)
          not(find_serve_block(file).nil?)
        end
        
        # Prepare the context for instantiating a given file
        def prepare_serve(url, file, app)
          (block = find_serve_block(file)) and block.call(url, file, self)
        end
        
        # Handles a not found strategy
        def handle_not_found(url)
          if notfound
            notfound.call(url, nil, self)
          else
            [404, {'Content-Type' => 'text/plain'}, ['Page not found']]
          end
        end
        
        # Serves from an url array
        def serve_url_array(url, url_array = url.split('/'))
          if url_array.size == 1
            # End of recursion, serve this file
            file = url_array[0]
            
            # Take the preparation block
            if File.exists?(realpath = realpath(file))
              if (block = find_serve_block(file, inherits))
                block.call(url, realpath(file), self)
              else
                handle_not_found(url)
              end
            else
              handle_not_found(url)
            end
          else
            # For a child
            mine = url_array.shift
            if @children[mine]
              @children[mine].serve_url_array(url, url_array)
            else
              handle_not_found(url)
            end
          end
        end
        
        # Serves an URL
        def serve(url)
          url = url.strip
          url = url[1..-1] if url[0...1]=='/'
          serve_url_array(url)
        end
        
        # Returns the path of this .wawaccess file
        def to_s
          @read_file
        end
        
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw