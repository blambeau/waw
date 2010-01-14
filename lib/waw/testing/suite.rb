module Waw
  module Testing
    # A suite of wawspec scenarios
    class Suite
      
      # How many assertions?
      attr_accessor :assertion_count
      
      # How many failures?
      attr_accessor :failure_count
      
      # How many errors?
      attr_accessor :error_count
      
      # Creates a suite with given scenarios
      def initialize(scenarios)
        @scenarios = scenarios
        @assertion_count, @failure_count, @error_count = 0, 0, 0
      end
      
      # How many scenarios?
      def scenario_count
        @scenarios.size
      end
      
      # Runs the suite
      def run
        @scenarios.each do |sc|
          begin
            STDOUT.write('.')
            sc.run
            self.assertion_count += sc.assertion_count
          rescue Test::Unit::AssertionFailedError => ex
            # for ruby 1.8.6
            puts "\nAssertion failed #{sc.name}: #{ex.message}"
            puts ex.backtrace[0]
            self.failure_count += 1
          rescue MiniTest::Assertion => ex
            # for ruby 1.9.1
            puts "\nAssertion failed #{sc.name}: #{ex.message}"
            puts ex.backtrace[0]
            self.failure_count += 1
          rescue Exception => ex
            puts "Fatal error #{sc.name}: #{ex.message}"
            puts ex.backtrace.join("\n")
            self.error_count += 1
          end
        end
      end
      
    end # class Suite
  end # module Testing
end # module Waw