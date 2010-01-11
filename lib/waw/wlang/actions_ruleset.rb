module WLang
  class RuleSet
    module WawActionsRuleSet
      
      class ActionInjected
        
        # Creates an injection instance
        def initialize(action_name, uri)
          @action_name, @uri = action_name, uri
        end
        
        # Returns the unique id of the action
        def id
          @action_name
        end
        
        # Returns the matched URL
        def url
          @uri
        end
        alias :uri :url
        
        # Factors the ajax link for invoking this action in a <a onclick="...">
        def ajax_link(arguments = {})
          buffer = ""
          arguments.each_pair {|k, v| buffer << ", '#{k}' : '#{v}'"}
          "javascript:#{@action_name}({#{buffer[2..-1]}}, 'form##{@action_name}')"
        end
        
        # Factors the ajax code for preparing a formulary
        def ajax_form_preparer(opts = {})
          form_id = opts[:form_id] || @action_name
          <<-EOF
            <script type="text/javascript">
            	$(document).ready(function() {
            	  $("form##{form_id}").submit(function() {
            	    #{id}($("form##{form_id}").serialize(), "form##{form_id}");
              	  return false;
            	  });
              });
            </script>
          EOF
        end
        
      end
      
      # Default mapping between tag symbols and methods
      DEFAULT_RULESET = {'@' => :action}
  
      # Rule implementation of <tt>@{wlang/active-string}{...}</tt>.
      def self.action(parser, offset)
        service, reached = parser.parse(offset, "wlang/active-string")
        action_name = Waw::ActionController.extract_action_name(service)
        uri, action_id = service, action_name
        parser.context_push('action' => ActionInjected.new(action_name, uri))
          result, reached = parser.parse_block(reached)
        parser.context_pop
        [result, reached]
      end
      
    end
  end
end