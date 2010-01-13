# Following line allowing to run this file directly, bypassing the Rakefile
top  = File.join(File.dirname(__FILE__), '..', '..')
$LOAD_PATH.unshift(File.join(top, 'lib'), File.join(top, 'test', 'unit'))

# Requires
require '+{project.lowname}'
require 'test/unit'

# Load the waw application for having configuration
Waw.load_application(top)
raise "Tests cannot be run in production mode, to avoid modifying real database "\
      "or sending spam mails to real users." unless Waw.config.deploy_mode=='devel'

# Load all tests now
test_files = Dir[File.join(File.dirname(__FILE__), '**/*_test.rb')]
test_files.each { |file| require(file) }

