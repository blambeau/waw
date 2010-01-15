require "rake/rdoctask"
require "rake/testtask"
require "rake/gempackagetask"
require "rubygems"

dir     = File.dirname(__FILE__)
lib     = File.join(dir, "lib", "waw.rb")
version = File.read(lib)[/^\s*VERSION\s*=\s*(['"])(\d\.\d\.\d)\1/, 2]

task :default => [:test]

desc "Lauches all tests"
Rake::TestTask.new do |test|
  test.libs       = [ "lib", "test/unit" ]
  test.test_files = [ 'test/integration/**/*.rb', 'test/unit/test_all.rb']
  test.verbose    =  true
end

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
  s.executables = ["waw"]
  s.author = "Bernard Lambeau"
  s.email = "blambeau@gmail.com"
  s.homepage = "http://github.com/blambeau/waw"
end
Rake::GemPackageTask.new(gemspec) do |pkg|
	pkg.need_tar = true
end
