require 'rake/testtask'
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

