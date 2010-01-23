# Loads requires, basing on curent waw code, not a rubygems one
here = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(here, '..', '..', '..', 'lib'))
require 'waw'
require 'waw/wspec'
require 'waw/wspec/runner'

Waw.autoload(File.join(here, '..'))
test_files = Dir[File.join(File.dirname(__FILE__), '**/*.wspec')]
test_files.each { |file| load(file) }