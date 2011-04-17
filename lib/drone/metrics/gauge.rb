module Drone
  module Metrics
    
    ##
    # Gauge are linked to a block of code which
    # will be called when the value is asked, the block
    # is expected to return a number
    # 
    class Gauge
      attr_reader :name
    
      def initialize(name, &block)
        raise "Block expected" unless block
        @name = name
        @block = block
      end
    
      def value
        @block.call()
      end
    end
    
  end
end
