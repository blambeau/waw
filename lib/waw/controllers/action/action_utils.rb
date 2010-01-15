module Waw
  class ActionController < Waw::Controller
    #
    # Common utilities about actions.
    #
    module ActionUtils
      
      # Extracts the action name from a given path
      def extract_action_name(path)
        return $1.to_sym if path =~ /([a-zA-Z_]+)$/
        nil
      end
    
      # Checks if an action exists
      def has_action?(name)
        name = extract_action_name(name) unless Symbol===name
        return false unless name
        actions.has_key?(name)
      end
      
      def find_action(name)
        name = extract_action_name(name) unless Symbol===name
        return nil unless name
        actions[name]
      end
      
    end # module ActionUtils
  end # class ActionController
end # module Waw