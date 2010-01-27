# Following line allowing to run this file directly, bypassing the Rakefile
root  = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
top  = File.join(File.dirname(__FILE__), '..', '..')
$LOAD_PATH.unshift(File.join(root, 'lib'), File.join(top, 'lib'))
require 'waw'
require 'waw/wspec'
require 'waw/wspec/runner'

# Load the waw application for having configuration
Waw.autoload(top)
raise "Tests cannot be run in production mode, to avoid modifying real database "\
      "or sending spam mails to real users." unless ['devel', 'test'].include?(Waw.config.deploy_mode)

# Load all tests now
test_files = Dir[File.join(File.dirname(__FILE__), '**/*.wspec')]
test_files.each { |file| load(file) }

# Unload waw after all
#at_exit { Waw.unload }