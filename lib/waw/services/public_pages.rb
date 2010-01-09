module Waw
  module Services
    # 
    # A waw service that serves public pages expressed in wlang wtpl format
    #
    class PublicPages < Waw::Controller
      
      # Service installation on a rack builder
      def install_on_rack_builder(config, builder)
        myself = self
        public_dirs = []
        Dir["#{public_folder}/*"].each do |dir|
          public_dirs << "/#{File.basename(dir)}" if File.directory?(dir) and is_public?(dir)
        end
        Waw.logger.info("Starting public service on #{public_dirs.inspect}")
        builder.use Rack::Static, :urls => public_dirs, :root => File.basename(public_folder)
        builder.map('/') do 
          run myself
        end
      end
      
      ##############################################################################################
      ### Class or instance utilities
      ##############################################################################################
      module Utils
        
        # Normalizes a requested path, removing any .html, .htm suffix
        def normalize_req_path(req_path)
          # 1) Strip first
          req_path = req_path.strip
          # 2) Remove first slash 
          req_path = req_path[1..-1] if req_path[0,1]=='/'
          # 3) Remove last slash
          req_path = req_path[0..-2] if req_path[req_path.length-1,1]=='/'
          # 4) Remove trailing extensions
          req_path = $1 if req_path =~ /^(.*?)(\.html?)?$/
          # 5) Puts the first slash now
          req_path = "/#{req_path}"
          # 6) Handle /index
          req_path = "/" if req_path == "/index"
          # 7) Remove trailing index if any
          req_path = $1 if req_path =~ /^(.+)\/index$/
          req_path
        end
    
        # Relativize a path against a given folder
        def relativize(file, folder)
          file, folder = File.expand_path(file), File.expand_path(folder)
          file[(folder.length+1)..-1]
        end
    
      end # module Utils
      include Utils
      
      ##############################################################################################
      ### About service options
      ##############################################################################################
      
      # Default options of this service
      DEFAULT_OPTIONS = {:templates_folder => 'templates',
                         :public_folder    => 'public',
                         :pages_folder     => File.join('public', 'pages'),
                         :main_template    => 'layout.wtpl'}
      
      # Checks some service options
      def self.check_options(options = DEFAULT_OPTIONS)
        tf, pf, mt = options[:templates_folder], options[:pages_folder], options[:main_template]
        raise ArgumentError, "Bad service options #{options.inspect}", caller if tf.nil? or pf.nil? or mt.nil?
        raise ArgumentError, "Bad templates folder #{tf}", caller unless File.exists?(tf)
        raise ArgumentError, "Bad pages folder #{pf}", caller unless File.exists?(pf)
        raise ArgumentError, "Bad main template #{mt}", caller unless File.exists?(File.join(tf, mt))
      end
      
      ##############################################################################################
      ### About service creation and configuration
      ##############################################################################################
      
      # The options
      attr_reader :options
      
      # Creates a service instance
      def initialize(opts = DEFAULT_OPTIONS)
        self.class.check_options(opts)
        @options = opts
      end
      
      # Returns the template folder
      def templates_folder
        options[:templates_folder]
      end
      
      # Returns the pages folder
      def public_folder
        options[:public_folder]
      end
      
      # Returns the pages folder
      def pages_folder
        options[:pages_folder]
      end
      
      # Returns the pages folder
      def main_template
        options[:main_template]
      end
      
      # Checks if a given folder is considered public
      def is_public?(dir)
        dir = File.expand_path(dir)
        not([pages_folder, templates_folder].collect{|f| File.expand_path(f)}.include?(dir))
      end
      
      # Resolves the location of the titles file
      def titles_file
        File.join(pages_folder, 'titles.txt')
      end
      
      ##############################################################################################
      ### About titles
      ##############################################################################################
    
      # Lazy load of all titles
      def titles
        @titles ||= load_titles
      end
    
      # Loads the titles from the title descriptor file
      def load_titles
        titles = {}
        if File.exists?(titles_file)
          File.open(titles_file).readlines.each do |line|
            line = line.strip
            next if line.empty?
            raise "Title file corrupted on line |#{line}|" unless /^([\/a-zA-Z0-9_-]+)\s+(.*)$/ =~ line
            titles[$1] = $2
          end
          Waw.logger.debug("PublicPages service: titles loaded successfully")
        else
          Waw.logger.info("PublicPages service: no titles.txt file")
        end  
        titles
      end
    
      # Returns the title of a normalized requested path
      def title_of(req_path)
        title = titles[req_path]
        unless title
          Waw.logger.warn("Warning, no dedicated title for #{req_path}")
          title = titles['/']
        end
        title
      end
    
      ##############################################################################################
      ### Main service execution
      ##############################################################################################
    
      # Find the template file corresponding to a normalized requested path. Returns nil if no
      # such file can be found.
      def find_requested_page_file(req_path)
        # 1) Remove first slash
        req_path = req_path[1..-1]
        # 2) Map to a file
        file = File.join(pages_folder, *req_path.split("/"))
        # 3) Seems a folder?
        if File.exists?(file) and File.directory?(file)
          file = File.join(file, 'index.wtpl')
        else
          file = "#{file}.wtpl"
        end
        (File.exists?(file) and File.file?(file)) ? relativize(file, pages_folder) : nil
      end
    
      # Executes the service
      def execute(env, req, res)
        # find the main page to compose
        req_path = normalize_req_path(req.path)
        req_path, is404, page = req_path, false, find_requested_page_file(req_path)
      
        # handle 404
        req_path, is404, page = '/', true,  find_requested_page_file('/') unless page
      
        # compose it
        context = {"title"       => title_of(req_path), 
                   "pagerequest" => page,
                   "env"         => env,
                   "request"     => req, 
                   "response"    => res}
        layout = File.join(templates_folder, main_template)
        composed = WLang.file_instantiate(layout, context).to_s
      
        # send result
        [:bypass, [is404 ? 404 : 200, {'Content-Type' => 'text/html'}, [composed]]]
      end
    
    end # class PublicPages
  end # module Services
end # module Waw