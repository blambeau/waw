module Waw
  module Routing
    # The DSL for routing blocks
    class DSL 
      
      # Creates a DSL instance for some routing instance
      def initialize(routing)
        @routing = routing
      end
      
      # Evaluates the block as routing execution and installs it
      # under all provided action results
      def upon(*action_results)
        raise ArgumentError, "Missing routing block on upon", caller unless block_given?
        @routing.add_rules(action_results, yield)
      end
      
      # Feedback routing execution
      def feedback(*args)
        Waw::Routing::Feedback.new(*args)
      end
      
      # Form validation feedback routing execution
      def form_validation_feedback(*args)
        Waw::Routing::FormValidationFeedback.new(*args)
      end
      
      # Refresh routing execution
      def refresh(*args)
        Waw::Routing::Refresh.new(*args)
      end
      
      # Redirect routing execution
      def redirect(*args)
        Waw::Routing::Redirect.new(*args)
      end
      
    end # class DSL
  end # module Routing
end # module Waw
