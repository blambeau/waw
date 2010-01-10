module WLang
  class RuleSet
    module WawActionsRuleSet
      
      # Default mapping between tag symbols and methods
      DEFAULT_RULESET = {'@' => :action}
  
      # Generates a bundle for form invocation
      def self.server_invoke_form_helper(service, form_contents)
        id = Waw::ActionController.extract_action_name(service)
        <<-EOF
          <form action="#{service}" method="post" enctype="multipart/form-data" id="#{id}">
            #{form_contents}
          </form>
          <script type="text/javascript">
          	$(document).ready(function() {
          	  $("form##{id}").submit(function() {
          	    #{id}();
            	  return false;
          	  });
            });
          </script>
        EOF
      end
      
      # Rule implementation of <tt>@{wlang/active-string}{...}</tt>.
      def self.action(parser, offset)
        service, reached = parser.parse(offset, "wlang/active-string")
        result, reached = parser.parse_block(reached)
        result = server_invoke_form_helper(service, result)
        [result, reached]
      end
      
    end
  end
end