require File.expand_path('../metric', __FILE__)

module Drone
  module Metrics
    
    class Counter
      attr_reader :value, :name
    class Counter < Metric
      attr_reader :value
    
      def initialize(name, initial_value = 0)
        super(name)
        
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