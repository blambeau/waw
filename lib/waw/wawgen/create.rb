require 'optparse'
require 'fileutils'
module Waw
  module Wawgen
    # Implementation of 'waw create'
    class Create
      
      # Which layout
      attr_reader :layout
      
      # Force overrides?
      attr_reader :force

      # Creates a command instance
      def initialize
        @layout = 'empty'
        @force = false
      end

      # Parses commandline options provided as an array of Strings.
      def options
        @options  ||= OptionParser.new do |opt|
          opt.program_name = File.basename $0
          opt.version = WLang::VERSION
          opt.release = nil
          opt.summary_indent = ' ' * 4
          banner = <<-EOF
            # Usage waw create [options] ProjectName
      
            # Creates an initial waw project structure
          EOF
          opt.banner = banner.gsub(/[ \t]+# /, "")
    
          opt.separator nil
          opt.separator "Options:"
    
          opt.on("--force", "-f", "Erase any exsting file on conflict") do |value|
            @force = true
          end

          opt.on("--layout=LAYOUT", "-l", "Use a specific waw layout (default empty)") do |value|
            @layout = value
          end

          opt.on("--verbose", "-v", "Display extra progress as we parse.") do |value|
            @verbosity = 2
          end

          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opt.on_tail("-h", "--help", "Show this message") do
            puts options
            exit
          end

          # Another typical switch to print the version.
          opt.on_tail("--version", "Show version") do
            puts "waw version " << Waw::VERSION << " (c) University of Louvain, Bernard & Louis Lambeau"
            exit
          end
    
          opt.separator nil
        end
      end

      # Runs the command
      def run(argv)
        # parse options
        rest = options.parse!(argv)
        if rest.length != 1
          puts options
          exit(-1)
        end
        
        # check project name
        project_name = rest[0]
        exit("Invalid project name #{project_name}, must start with [a-zA-Z]") unless /^[a-zA-Z]/ =~ project_name
        if project_name =~ /^[a-z]/
          project_name = (project_name[0...1].upcase + project_name[1..-1]) 
          puts "Warning: using #{project_name} as project name for ruby needs..."
        end
        
        # create project
        project = ::Waw::Wawgen::Project.new(project_name)
        begin
          generate(project)
        rescue WLang::Error => ex
          puts ex.message
          puts ex.wlang_backtrace.join("\n")
          puts ex.backtrace.join("\n")
        end
      end
      
      # Puts an error message and exits
      def exit(msg)
        puts msg
        Kernel.exit(-1)
      end

      def generate_recursively(project, layout_folder, target_folder)
        # Generate files now
        Dir.new(layout_folder).each do |file|
          next if ['.', '..', 'dontforgetme'].include?(file)
          next if 'dependencies'==file
          target = File.join(target_folder, file.gsub('project', project.lowname))
          puts "Generating #{target} from #{layout}/#{file}"

          if File.directory?(source=File.join(layout_folder, file))
            FileUtils.mkdir_p target unless File.exists?(target)
            generate_recursively(project, source, target)
          else
            File.open(target, 'w') do |io|
              if /jquery/ =~ file
                io << File.read(File.join(layout_folder, file))
              else
                context = {"project" => project}
                io << WLang.file_instantiate(File.join(layout_folder, file), context, 'wlang/active-string', :parentheses).to_s
              end
            end
          end
        end
      end

      # Generates a given layout for a specific project
      def generate_layout(project, layout)
        # Locate the layout folder
        layout_folder = File.join(File.dirname(__FILE__), '..', '..', '..', 'layouts', layout)
        puts File.expand_path(layout_folder)
        exit("Unknown layout #{layout}") unless File.exists?(layout_folder)
        
        # Handle dependencies
        dependencies_file = File.join(layout_folder, 'dependencies')
        if File.exists?(dependencies_file)
          File.readlines(dependencies_file).each do |line|
            next if /^#/ =~ (line = line.strip)
            line.split(/\s/).each do |word| 
              generate_layout(project, word)
            end
          end
        end
        
        # Let recursive generation occur
        puts "Generating recursively project, #{layout_folder}, #{project.folder}"
        generate_recursively(project, layout_folder, project.folder)
      end

      # Generates the project
      def generate(project)
        # A small debug message and we start
        puts "Generating project with names #{project.upname} inside #{project.lowname} using layout #{layout}"
        
        # 1) Create the output folder if it not exists
        if File.exists?(project.folder) and not(force)
          exit("The project folder #{project.lowname} already exists. Remove it first")
        else
          FileUtils.rm_rf project.folder if File.exists?(project.folder)
          FileUtils.mkdir_p project.folder
        end

        generate_layout(project, layout)
        FileUtils.chmod 0755, File.join(project.root, 'config.ru')
      end
      
    end # class Create
  end # module Wawgen
end # module Waw