require 'cgi'
module Waw
  class ErrorHandler < ::Waw::Controller
    class Backtrace
      
      # Converts a back-trace to a friendly HTML chunck
      def ex_backtrace_to_html(backtrace)
        "<div>" + backtrace.collect{|s| CGI.escapeHTML(s)}.join('</div><div>') + "</div>"
      end
    
      # Converts an exception to a friendly HTML chunck
      def ex_to_html(ex, backtrace)
        <<-EOF
          <html>
            <head>
              <style type="text/css">
                body {
                  font-size: 14px;
                	font-family: "Courier", "Arial", sans-serif;
                }
                p.message {
                  font-size: 16px;
                  font-weight: bold;
                }
              </style>
            </head>
            <body>
              <h1>Internal server error (ruby exception)</h1>
              <p class="message"><code>#{CGI.escapeHTML(ex.message)}</code></p>
              <div style="margin-left:50px;">
                #{ex_backtrace_to_html(backtrace)}
              </div>
            </body>
          </html>
        EOF
      end
      
      # Shows a page with a friendly presented backtrace for the error
      # that occured
      def call(kernel, ex)
        backtrace = case ex
          when ::WLang::Error
            ex.wlang_backtrace
          when ::Exception
            ex.backtrace
          else 
            []
        end
        [500, {'Content-Type' => 'text/html'}, ex_to_html(ex, backtrace)]
      end
      
    end # class Backtrace
  end # module ErrorHandler
end # module Waw