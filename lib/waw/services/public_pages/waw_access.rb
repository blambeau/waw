module Waw
  module Services
    module PublicPages
      # Waw version of .htaccess files
      class WawAccess < Waw::Controller
        
        # The folder which is served
        attr_accessor :folder
        
        # Strategy :allow_all or :deny_all
        attr_accessor :strategy
        
        # Does it inherits its parent configuration?
        attr_accessor :inherits
        
        # The parent wawaccess file
        attr_accessor :parent
        
        # File currently served
        attr_accessor :served_file
        
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
          raise ArgumentError, "Invalid folder #{root_folder}" unless (root_folder and File.directory?(root_folder))

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
          block = Kernel.lambda{|url, realpath, wawaccess, env| app.static(realpath, env) } unless block
          patterns.each do |pattern|
            @serve << [pattern, block]
          end
        end
        
        # Merges a DSL string inside this waw access
        def dsl_merge(dsl_str, read_file=nil)
          begin
            WawAccess::DSL.new(self).instance_eval(dsl_str)
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
          File.expand_path(File.join(folder, file))
        end
        
        # Locates the file that would be matched by a given normalized
        # url.
        def matching_file(path)
          File.join(root.folder, path)
        end
        
        # Relativize a path against a given folder
        def relativize(file, folder = folder)
          file, folder = File.expand_path(file), File.expand_path(folder)
          file[(folder.length+1)..-1]
        end
        
        ################################################### Utilities about the hierarchy
        
        # Returns an identifier for this wawaccess
        def identifier(append = true)
          if parent
            parent.identifier(false) + (append ? "#{File.basename(@folder)}/.wawaccess" : File.basename(@folder))
          else
            (append ? ".wawaccess" : "")
          end
        end
        
        # Returns the root waw access in the hierarchy
        def root
          @root ||= (parent ? parent.root : self)
        end
        
        # Finds the wawaccess instance for a given url
        def find_wawaccess_for(url, url_array = url.split('/').reject{|k| k.empty?})
          if url_array.empty?
            self
          else
            if @children.has_key?(nextfolder = url_array.shift)
              @children[nextfolder].find_wawaccess_for(url, url_array)
            else
              self
            end
          end
        end
        
        ################################################### .waw access rules application!
        
        # Finds the matching block inside this .wawaccess handler
        def find_matching_block(path)
          @serve.each do |pattern, block|
            case pattern
              when FalseClass
              when TrueClass
                return block
              when String
                if pattern=='*'
                  return block
                elsif /^\*?\.[a-z]+$/ =~ pattern
                  return block if File.extname(realpath(path))==pattern
                else
                  return block if File.basename(realpath(path))==pattern
                end
              when Regexp
                return block if pattern =~ path
              when Waw::Validation::Validator
                return block if pattern.validate(matching_file(path))
              else
                raise WawError, "Unrecognized wawaccess pattern #{pattern}"
            end
          end
          nil
        end 
        
        # Applies the rules defined here or delegate to the parent if allowed
        def apply_rules(path)
          if block = find_matching_block(path)
            duplicated = self.dup
            duplicated.served_file = path
            duplicated.instance_eval(&block)
          elsif (parent and inherits)
            parent.apply_rules(path)
          else
            body = "File not found: #{path}\n"
            [404, {"Content-Type" => "text/plain",
               "Content-Length" => body.size.to_s,
               "X-Cascade" => "pass"},
             [body]]
          end
        end
        
        ################################################### To be called on the tree root only!
        
        # Normalizes a requested path, removing any .html, .htm suffix
        def normalize_req_path(req_path)
          # 1) Strip first
          req_path = req_path.strip
          # 2) Remove first slash 
          req_path = req_path[1..-1] if req_path[0,1]=='/'
          # 3) Remove last slash
          req_path = req_path[0..-2] if req_path[req_path.length-1,1]=='/'
          req_path
        end
    
        # Serves a path from a root waw access in the hierarchy
        def do_path_serve(path)
          #puts "Do path serve with #{identifier} on #{path}"
          path = normalize_req_path(path)
          waw_access = (find_wawaccess_for(path) || self)
          #puts "Found #{waw_access.identifier}"
          waw_access.apply_rules(path)
        end
        
        ################################################### Callbacks proposed to .wawaccess rules
        
        # Deny access to the file
        def deny
          body = "Forbidden\n"
          [403, {"Content-Type" => "text/plain",
                 "Content-Length" => body.size.to_s,
                 "X-Cascade" => "pass"},
           [body]]
        end
        
        # Serves a static file from a real path
        def static
          if Waw.env
            @file_server ||= ::Rack::File.new(folder)
            env["PATH_INFO"] = served_file
            @file_server.call(Waw.env)
          else
            path = File.join(root.folder, served_file)
            [200, {'Content-Type' => 'text/plain'}, [File.read(path)]]
          end
        end
        
        # Run a rewriting
        def apply(path, result_override = nil, headers_override = {})
          result = root.do_path_serve(path)
          [result_override || result[0], 
           result[1].merge(headers_override),
           result[2]]
        end
        
        # Instantiates wlang on the current file, with a given context
        def wlang(context = {}, content_type = 'text/html')
          path = File.join(root.folder, served_file)
          [200, {'Content-Type' => content_type}, [WLang.file_instantiate(path, context).to_s]]
        end
        
        ################################################### Methods for Rack application and Waw services
        
        # Service installation on a rack builder
        def factor_service_map(config, map)
          map['/'] = self
          map
        end
        
        # Rack application here
        def execute(env, request, response)
          do_path_serve(env["PATH_INFO"])
        end
        
      end # class WawAccess
    end # module PublicPages
  end # module Services
end # module Waw