require "rubygems"
require "waw"

# The following lines will automatically load all your .rb files
# located in the project structure
here = File.dirname(__FILE__)
Dir[File.join(here, '+(project.lowname)', '**/', '*.rb')].each {|f| require(f)}

# Main namespace of +(project.upname)
module +(project.upname)
  
  # Version number of +(project.upname)
  VERSION = "0.0.4".freeze
  
end # module +(project.upname)