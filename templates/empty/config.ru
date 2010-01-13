require 'rubygems'
require 'waw'
if app = Waw.load_application(File.dirname(__FILE__))
  run app
else
  puts "Unable to start webapp, see logs"
end
