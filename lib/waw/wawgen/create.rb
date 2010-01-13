require 'optparse'
require 'fileutils'
module Waw
  module Wawgen
    # Implementation of 'waw create'
    class Create
      
      # Which template
      attr_reader :template

      # Creates a command instance
      def initialize
        @template = 'empty'
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
        
        # create project
        project = ::Waw::Wawgen::Project.new(rest[0])
        generate(project)
      end
      
      # Puts an error message and exits
      def exit(msg)
        puts msg
        Kernel.exit(-1)
      end

      # Generates the project
      def generate(project)
        # A small debug message and we start
        puts "Generating project with names #{project.upname} inside #{project.lowname} using template #{template}"
        
        # 1) Create the output folder if it not exists
        if File.exists?(project.folder)
          exit("The project folder #{project.lowname} already exists. Remove it first")
        else
          FileUtils.mkdir_p project.folder
        end

        # Locate the template folder
        template_folder = File.join(File.dirname(__FILE__), '..', '..', '..', 'layouts', template)
        exit("Unknown template #{template}") unless File.exists?(template_folder)
        
        # Generate files now
        Dir["#{template_folder}/**/*"].each do |file|
          file = file[template_folder.length+1..-1]
          next if 'install.rb'==file
          target = File.join(project.root, file.gsub('project', project.lowname))
          puts "Generating #{target}..."

          if File.directory?(File.join(template_folder, file))
            FileUtils.mkdir_p target
          else
            File.open(target, 'w') do |io|
              context = {"project" => project}
              WLang.file_instantiate(File.join(template_folder, file), context, io, 'wlang/active-string')
            end
          end
        end
        FileUtils.chmod 0755, File.join(project.root, 'config.ru')
        
      end
      
    end # class Create
  end # module Wawgen
end # module Waw