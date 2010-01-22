module Waw
  module Routing
    # FormValidationFeedback routing
    class FormValidationFeedback < RoutingRule

      def initialize(opts = {})
        @options = opts
      end

      def generate_js_code(result, align=0)
        buffer = ""
				buffer << " "*align + "str = '';\n"
				buffer << " "*align + "str += '<ul>';\n"
				buffer << " "*align + "for (var k in data[1]) {\n"
				buffer << " "*(align+2)	+ "str += '<li>' + messages[data[1][k]] + '</li>';\n"
				buffer << " "*align + "}\n"
				buffer << " "*align + "str += '</ul>';\n"
				buffer << " "*align + "$(form + ' .feedback').show();\n"
				buffer << " "*align + "$(form + ' .feedback').html(str);\n"
				if @options[:scroll]
  				where = case @options[:scroll]
    			  when :top
  			      '0'
  			    when :form
  			      "$(form).offset().top"
  			    when :feedback
  			      "$(form + ' .feedback').offset().top"
  			  end
          buffer << "$('html, body').animate( { scrollTop: #{where} }, 'slow' );\n"
  			end
        buffer
      end
      
    end # class FormValidationFeedback
  end # module Routing
end # module Waw