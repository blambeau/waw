module Waw
  module Services
    # Helper to create json server services
    class JSONServices
      
      module Utils
      
        # Checks if a service response matches some expected pattern
        def matches?(json_response, what)
          raise ArgumentError, "Array expected as json_response" unless Array===json_response
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
        
      end # Utils
      
      extend Utils
    end # class JSONServices
  end # module Services
end # module Waw