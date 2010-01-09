module Waw
  module Routing
    #
    # Routing rules installed on an action
    #
    class ActionRouting
      
      # Creates an empty routing table. If a block is given, executes it
      # as a Routing DSL
      def initialize(&block)
        @rules = {}
        DSL.new(self).instance_eval(&block) if block
      end
      
      # Add some routing rules
      def add_rules(action_results, exec)
        action_results.each {|actr| @rules[actr] = exec}
      end
    
    end # class ActionRouting
  end # module Routing
end # module Waw
