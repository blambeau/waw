module Waw
  module Routing
    # FormValidationFeedback routing
    class FormValidationFeedback < RoutingRule

      def generate_js_code(result, align=0)
        buffer = ""
				buffer << " "*align + "str = '';\n"
				buffer << " "*align + "str += '<ul>';\n"
				buffer << " "*align + "for (var k in data[1]) {\n"
				buffer << " "*(align+2)	+ "str += '<li>' + messages[data[1][k]] + '</li>';\n"
				buffer << " "*align + "}\n"
				buffer << " "*align + "str += '</ul>';\n"
				buffer << " "*align + "$(form + ' .feedback').show();"
				buffer << " "*align + "$(form + ' .feedback').html(str);"
        buffer
      end
      
    end # class FormValidationFeedback
  end # module Routing
end # module Waw