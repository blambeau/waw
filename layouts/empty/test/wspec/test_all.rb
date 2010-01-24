# Following line allowing to run this file directly, bypassing the Rakefile
top  = File.join(File.dirname(__FILE__), '..', '..')
$LOAD_PATH.unshift(File.join(top, 'lib'), File.join(top, 'test', 'unit'))

# Requires
require 'rubygems'
require 'waw'
require '+(project.lowname)'
require 'waw/wspec'
require 'waw/wspec/runner'

# Load the waw application for having configuration
Waw.autoload(File.join(top, 'config.ru'))
raise "Tests cannot be run in production mode, to avoid modifying real database "\
      "or sending spam mails to real users." unless ['devel', 'test'].include?(Waw.config.deploy_mode)

# Load all tests now
test_files = Dir[File.join(File.dirname(__FILE__), '**/*.wspec')]
test_files.each { |file| load(file) }

# Unload waw after all
#at_exit { Waw.unload }