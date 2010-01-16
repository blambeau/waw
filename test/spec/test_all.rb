$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'waw'
require 'spec/autorun'
test_files = Dir[File.join(File.dirname(__FILE__), '**/*_spec.rb')]
test_files.each { |file|
  require(file) 
}

