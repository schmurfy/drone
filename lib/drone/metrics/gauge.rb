require File.expand_path('../metric', __FILE__)

module Drone
  module Metrics
    
    ##
    # Gauge are linked to a block of code which
    # will be called when the value is asked, the block
    # is expected to return a number
    # 
    class Gauge < Metric
    
      def initialize(name, &block)
        raise "Block expected" unless block
        super(name)
        @block = block
      end
    
      def value
        @block.call()
      end
    end
    
  end
end
