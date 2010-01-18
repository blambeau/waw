module Waw
  module Validation
    class Error < StandardError
      
      # The list of failures
      attr_accessor :failed 
      
      # Creates a validation error instance
      def initialize(failed, msg = "Validation has failed #{failed.inspect}")
        super(msg)
        @failed = failed
      end 
      
    end
    class KO < Error; end
  end
end # module Waw