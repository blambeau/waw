require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"
require "rspec/core/rake_task"
require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "waw.rb")

task :default => [:unit]

desc "Lauches all unit tests"
Rake::TestTask.new(:unit) do |test|
  test.libs       = [ "lib", "test/unit" ]
  test.test_files = [ 'test/unit/test_all.rb']
  test.verbose    =  true
end

desc "Lauches integration tests on layouts"
Rake::TestTask.new(:layouts) do |test|
  test.libs       = [ "lib", "test/unit" ]
  test.test_files = [ 'test/integration/**/*.rb' ]
  test.verbose    =  true
end

desc "Lauches integration tests on examples"
Rake::TestTask.new(:examples) do |test|
  test.libs       = [ "lib", "test/unit" ]
  test.test_files = [ 'examples/test_all.rb' ]
  test.verbose    =  true
end

desc "Lauches integration tests on bricks"
Rake::TestTask.new(:bricks) do |test|
  test.libs       = [ "lib", "test/unit" ]
  test.test_files = [ 'test/bricks/test_all.rb' ]
  test.verbose    =  true
end

desc "Run all rspec test"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = ['-I.']
  t.pattern = 'test/spec/test_all.rb'
end

desc "Lauches all tests"
task :test => [:unit, :spec]

desc "Generates rdoc documentation"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include( "README.rdoc", "LICENCE.rdoc", "lib/" )
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_dir = "doc/api"
  rdoc.title    = "Waw - making web applications simple"
end