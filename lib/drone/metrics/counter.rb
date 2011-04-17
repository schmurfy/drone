module Drone
  module Metrics
    
    class Counter
      attr_reader :value, :name
    
      def initialize(name, initial_value = 0)
        @name = name
        @value = initial_value
      end
    
      def increment(n = 1)
        @value += n
      end
      alias :inc :increment
    
      def decrement(n = 1)
        @value -= n
      end
      alias :dec :decrement
    
      def clear
        @value = 0
      end
    end
    
  end
end