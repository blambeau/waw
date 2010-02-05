# Requires
require 'rubygems'
gem 'waw', '>= +(Waw::VERSION)'
require 'waw/wspec/runner'

# Load the waw application for having configuration
app = Waw.autoload(__FILE__)
raise "Tests cannot be run in production mode, to avoid modifying real database "\
      "or sending spam mails to real users." unless ['devel', 'test'].include\?(app.config.deploy_mode\)

# Load all tests now
test_files = Dir[File.join(File.dirname(__FILE__), '**/*.wspec')]
test_files.each { |file| load(file) }
