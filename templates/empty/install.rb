require 'rubygems'
require 'wlang'
require 'fileutils'
FU = FileUtils

# Puts an error message and exits
def exit(msg)
  puts msg
  Kernel.exit(-1)
end

# 1) Argument validations
exit("Usage: ruby install.rb ProjectName") unless ARGV.size == 1

class Project
  
  # Upper case name of the project
  attr_reader :upname
  
  # Lower case name of the project
  attr_reader :lowname
  
  # Creates a project instance
  def initialize(name)
    @upname, @lowname = name, lower(name)
  end
  
  # Returns root folder
  def root
    lowname
  end
  
  # Handle project name
  def lower(str)
    lowered = str.gsub(/[A-Z]/) {|s| s.swapcase} 
    lowered = lowered[1..-1] if lowered[0...1]=='_'
    lowered
  end
  
end

# Creates the project
project = Project.new(ARGV[0])

# 1) Create the output folder if it not exists
if File.exists?(project.lowname)
  FU.rm_rf(project.lowname)
  #exit("The project folder #{project.lowname} already exists. Remove it first")
else
  FU.mkdir_p project.lowname
end

here = File.dirname(__FILE__)
Dir["#{here}/**/*"].each do |file|
  file = file[here.length+1..-1]
  next if 'install.rb'==file
  target = File.join(project.root, file.gsub('project', project.lowname))
  puts "Generating #{target}..."

  if File.directory?(File.join(here, file))
    FU.mkdir_p target
  else
    File.open(target, 'w') do |io|
      context = {"project" => project}
      WLang.file_instantiate(File.join(here, file), context, io, 'wlang/active-string')
    end
  end
end
FU.chmod 0755, File.join(project.root, 'config.ru')