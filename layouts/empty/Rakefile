require "rake/rdoctask"
require "rake/testtask"
require "rubygems"
require "waw"

task :default => [:test]

desc "Launches all wspec tests"
task :wspec do
  require('test/wspec/test_all.rb')
end

desc "Launches all tests"
task :test => [:wspec]