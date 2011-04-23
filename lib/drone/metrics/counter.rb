require File.expand_path('../metric', __FILE__)

module Drone
  module Metrics
    
    ##
    # A Counter store a number which can go up or down,
    # the counter can change a counter value with
    # the methods increment and decrement aliased
    # as inc and dec
    # 
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