here = File.dirname(__FILE__)
top = File.join(here, '..', 'lib')
Dir["#{here}/**/test_all.rb"].each do |test|
  next if File.expand_path(test) == File.expand_path(__FILE__)
  puts
  puts "Executing #{test} example..."
  puts `ruby -I#{top} #{test}`
end