require 'waw'
require 'waw/testing'
require 'test/unit'
def scenario(name, &block)
  Waw::Testing::Scenario.new(&block)
end