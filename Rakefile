require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"
require 'spec/rake/spectask'
require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "waw.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

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

desc "Run all rspec test"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['test/spec/test_all.rb']
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

gemspec = Gem::Specification.new do |s|
  s.name = 'waw'
  s.version = version
  s.summary = "Waw - making web applications simple"
  s.description = %{A web application framework written in Ruby}
  s.files = Dir['lib/**/*'] + Dir['test/**/*'] + Dir['bin/*'] + Dir.glob('layouts/**/*', File::FNM_DOTMATCH)
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENCE.rdoc"]
  s.rdoc_options << '--title' << 'Waw - making web applications simple' <<
                    '--main' << 'README.rdoc' <<
                    '--line-numbers'  
  s.bindir = "bin"
  s.executables = ["waw", "wspec", "waw-start", "waw-profile"]
  s.author = "Bernard Lambeau"
  s.email = "blambeau@gmail.com"
  s.homepage = "http://github.com/blambeau/waw"
end
Rake::GemPackageTask.new(gemspec) do |pkg|
	pkg.need_tar = true
end
