require 'forwardable'
require File.expand_path('../histogram', __FILE__)
require File.expand_path('../meter', __FILE__)
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
      extend Forwardable
      
      def_delegators :@histogram, :count, :min, :max, :mean, :stdDev, :percentiles, :values
      
      def initialize(name)
        super(name)
        
        @histogram = Histogram.new("#{name}:histogram", :biased)
      end
      
      def count
        @histogram.count
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
