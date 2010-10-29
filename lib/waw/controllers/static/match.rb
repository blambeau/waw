module Waw
  class StaticController < ::Waw::Controller
    class WawAccess
      class Match
        include Waw::ScopeUtils
        
        attr_reader :wawaccess
        
        # Served file
        attr_reader :served_file
        
        # Creates a match instance with a block a arguments 
        # to pass
        def initialize(wawaccess, served_file, block, *args)
          @wawaccess, @served_file = wawaccess, served_file
          @block, @args = block, args
        end
        
        # Executes on a wawaccess instance
        def __execute(env)
          instance_exec *@args, &@block
        end
        
        # Delegated to the wawaccess that created me
        def root; @wawaccess.root; end
        def folder; @wawaccess.folder; end
        def req_path; @wawaccess.req_path; end
        
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
          if rack_env
            rack_env["PATH_INFO"] = served_file
            @wawaccess.file_server.call(rack_env)
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
      
        # Builds a default wlang contect
        def default_wlang_context
          context = {"css_files"   => root.find_files('css'),
                     "js_files"    => root.find_files('js'),
                     "served_file" => served_file}
          context
        end
      
        # Instantiates wlang on the current file, with a given context
        def wlang(template = nil, context = {}, result_override = nil, headers_override = {})
          if template.nil?
            template = File.join(root.folder, served_file)
          else
            template = File.join(folder, template)
          end
          context = default_wlang_context.merge(context || {})
          [result_override || 200, 
           {'Content-Type' => 'text/html'}.merge(headers_override || {}), 
            [::WLang.file_instantiate(template, context.unsymbolize_keys).to_s]]
        end

      end # class Match
    end # class WawAccess
  end # class StaticController
end # module Waw
