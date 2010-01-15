module Waw
  class ActionController < Waw::Controller
    # 
    # A Web action, inside an ActionController.
    # 
    class Action
    
      # Action controller
      attr_reader :controller
    
      # Action name
      attr_reader :name
      
      # Action signature (pre-conditions and validation)
      attr_reader :signature
      
      # Action routing
      attr_reader :routing
    
      # Creates an action instance
      def initialize(name, signature, routing, controller, method)
        @name, @signature, @routing = name, signature, routing
        @controller, @method = controller, method
        @routing = ::Waw::Routing::ActionRouting.new unless @routing
      end
      
      # Returns a unique id for this action in the architecture
      def id
        "#{controller.url}/#{name}"[1..-1].gsub('/', '_')
      end
      
      # Builds a href for this action, with optional parameters
      def href(params = nil)
        "#{controller.url}/#{name}" << (params ? "?#{params.to_url_query}" : "")
      end
      alias :url :href
      alias :uri :href
      
      # Factors the ajax link for invoking this action in a <a onclick="...">
      def ajax_link(arguments = {})
        buffer = ""
        arguments.each_pair {|k, v| buffer << ", '#{k}' : '#{v}'"}
        "javascript:#{id}({#{buffer[2..-1]}}, '##{id}')"
      end
      
      # Factors the ajax code for preparing a formulary
      def ajax_form_preparer(opts = {})
        form_id = opts[:form_id] || id
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
      
      # Executes the action inside a controller and using parameters
      def execute(params = {})
        ok, values = @signature.apply(params)
        if ok
          # validation is ok, merge params and continue
          [:success, @method.bind(controller.instance).call(params.merge!(values))]
        else
          # validation is ko
          [:"validation-ko", values]
        end
      end
    
    end # class Action
  end # class ActionController
end # module Waw