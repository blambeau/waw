require 'waw'
require 'waw/testing'
module Waw
  class WawSpec
    
    SCENARIOS = {}
    
  end
end
def scenario(name, &block)
  Waw::WawSpec::SCENARIOS[name] = Waw::Testing::Scenario.new(&block)
end