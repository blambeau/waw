module Waw
  module Fixtures
    class ActionControllerTest < ::Waw::ActionController
      
      signature {}
      def say_hello
        :hello
      end
      
    end
  end
end