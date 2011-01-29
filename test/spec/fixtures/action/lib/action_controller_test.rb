module Waw
  module Fixtures
    class ActionControllerTest < ::Waw::ActionController
      
      signature {}
      def say_hello(params)
        :hello
      end
      
    end
  end
end