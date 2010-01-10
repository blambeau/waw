module WLang
  class RuleSet
    module WawActionsRuleSet
      
      # Default mapping between tag symbols and methods
      DEFAULT_RULESET = {'@' => :action}
  
      # Generates a bundle for form invocation
      def self.server_invoke_form_helper(uri, id, form_contents)
        <<-EOF
          <form action="#{uri}" method="post" enctype="multipart/form-data" id="#{id}">
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
        action = if /^services(\.[a-z_]+)+$/ =~ service.strip
          raise "Unsupported so far"
          parser.evaluate(service)
        else
          action_name = Waw::ActionController.extract_action_name(service)
          #app = Waw.find_rack_app(service){|app| Waw::ActionController===app}
          #raise "Unable to find action for service url #{service}" unless app
          uri, action_id = service, action_name
        end
        result, reached = parser.parse_block(reached)
        result = server_invoke_form_helper(uri, action_id, result)
        [result, reached]
      end
      
    end
  end
end