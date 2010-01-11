module Waw
  module Routing
    
    #
    # Routing rules installed on an action
    #
    class ActionRouting
      
      # Creates an empty routing table. If a block is given, executes it
      # as a Routing DSL
      def initialize(&block)
        @rules = {}
        DSL.new(self).instance_eval(&block) if block
      end
      
      # Add some routing rules
      def add_rules(action_results, exec)
        action_results.each {|actr| @rules[actr] = exec}
      end
      
      def generate_js_if_then_else(table, key, level = 0, align = 0)
        case table
          when Hash
            if table.size==1 and table.has_key?('*')
              generate_js_if_then_else(table['*'], key, level, align)
            else
              first, buffer, space = true, "", " "
              
              # normal table
              table.each do |key, n|
                next if key=='*'
                code = "#{first ? space*align : ' else '}if (data[#{level}] == '#{key}') {\n" +
                       "#{generate_js_if_then_else(n, key, level+1, align+2)}\n" +
                       " "*align + "}"
                first = false
                buffer << code
              end
              
              if table.has_key?('*')
                buffer << " else {\n"
                buffer << generate_js_if_then_else(table['*'], key, level, align+1)
                buffer << " "*align + "}"
              end
              
              buffer
            end
          when RoutingRule
            table.generate_js_code(key, align)
          else
            raise "Unexpected table #{table}"
        end
      end
      
      # Generates the javascript routing
      def generate_js_routing(action, align=0)
        # Build the if-then-else table
        table = Hash.new {|h, k| h[k] = Hash.new}
        @rules.each do |pattern, rule|
          elements = pattern.split('/')
          raise "Unsupport action-routing pattern #{pattern}" if elements.size==0 or elements.size>2
          elements << '*' if elements.size == 1
          table[elements[0]][elements[1]] = rule
        end
        
        # Build the javascript code now
        generate_js_if_then_else(table, "", 0, align)
      end
      
      # Applies this action routing on a browser
      def apply_on_browser(result, browser)
        @rules.each_pair do |pattern, rule|
          rule.apply_on_browser(result, browser) if Waw::Routing.matches?(pattern, result)
        end
      end
    
    end # class ActionRouting
  end # module Routing
end # module Waw
