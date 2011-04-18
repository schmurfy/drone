
require File.expand_path('../histogram', __FILE__)
require File.expand_path('..//meter', __FILE__)

module Drone
  module Metrics
    class Timer
      attr_reader :name
      
      def initialize(name = 'calls')
        @name = name
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
      
      #
      # duration: milliseconds
      def update(duration)
        if duration >= 0
          @histogram.update(duration)
        end
      end
      
      #
      # time and record the duration of the block
      def time
        started_at = Time.now.to_f
        yield()
      ensure
        update(Time.now.to_f - started_at.to_f)
      end
      
    end
  end
end
