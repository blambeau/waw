module Waw
  module Routing
    # Feedback routing
    class Feedback < RoutingRule

      # Creates a feedback instance
      def initialize(opts = {})
        @opts = opts
      end

      def generate_js_code(result, align=0)
        buffer = ""
        buffer << " "*align + "$(form + ' input').hide();\n" if @opts[:hide_input]
        buffer << " "*align + "$(form + ' .feedback').show();\n"
        message = @opts[:message] ? "'#{@opts[:message]}'" : 'data[1][0]'
        buffer << " "*align + "$(form + ' .feedback').html(messages[#{message}]);"
        buffer
      end
      
    end # class Feedback
  end # module Routing
end # module Waw