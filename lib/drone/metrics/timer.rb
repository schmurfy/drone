
require File.expand_path('../histogram', __FILE__)
require File.expand_path('..//meter', __FILE__)
require File.expand_path('../metric', __FILE__)

module Drone
  module Metrics
    ##
    # The timer metric will record the time spent in a given method
    # or any block of code.
    # 
    # All the times are in milliseconds.
    # 
    class Timer < Metric
      
      def initialize(name = 'calls')
        super(name)
        @histogram = Histogram.new(Histogram::TYPE_BIASED)
        clear()
      end
      
      def count
        @histogram.count
      end
      
      # may requires a conversion... or not
      [:count, :min, :max, :mean, :stdDev, :percentiles, :values].each do |attr_name|
        define_method(attr_name) do |*args|
          @histogram.send(attr_name, *args)
        end
      end
      
      def clear
        @histogram.clear()
      end
      
      ##
      # Method used to record a new duration
      # 
      # @param [Float] duration A duration in milliseconds
      # 
      def update(duration)
        if duration >= 0
          @histogram.update(duration)
        end
      end
      
      ##
      # time and record the duration of the block
      # @yield [] The block to time
      # 
      def time
        started_at = Time.now.to_f
        yield()
      ensure
        update((Time.now.to_f - started_at.to_f) * 1000)
      end
      
    end
  end
end
