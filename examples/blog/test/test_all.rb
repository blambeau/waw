require 'waw/testing/wawspec'
Waw.autoload(File.join(File.dirname(__FILE__), '..'))
test_files = Dir[File.join(File.dirname(__FILE__), '**/*.wspec')]
test_files.each { |file| load(file) }