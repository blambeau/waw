require 'waw/routing/dsl'
require 'waw/routing/action_routing'
require 'waw/routing/routing_rule'
require 'waw/routing/feedback'
require 'waw/routing/form_validation_feedback'
require 'waw/routing/refresh'
require 'waw/routing/redirect'
module Waw
  module Routing
    module Methods
      
      # Checks if a service response matches some expected pattern
      def matches?(what, json_response = self)
        raise ArgumentError, "Array expected as json_response (#{json_response.inspect} found)" unless Array===json_response
        json_response = json_response.dup
        what.split('/').each do |elm|
          return false if json_response.empty?
          case part = json_response.shift
            when String, Symbol
              if elm == '*'
                # always ok here
              else
                return false unless part.to_s==elm.to_s
              end
            when Array
              if elm == '*'
                return false if part.empty?
              else
                return false unless part.any?{|e| e.to_s == elm.to_s} or (elm=='*')
              end
            else
              raise ArgumentError, "Unexpected part in json_response #{part}"
          end
        end
        true
      end
      alias :=~ :matches?
      
    end # module Methods 
    extend Methods
  end # module Routing
end # module Waw