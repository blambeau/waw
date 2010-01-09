require 'waw'
require 'waw/testing'
def scenario(name, &block)
  Waw::Testing::Scenario.new(&block)
end