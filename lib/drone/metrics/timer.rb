
require File.expand_path('../histogram', __FILE__)
require File.expand_path('..//meter', __FILE__)

module Drone
  module Metrics
    class Timer
      def initialize(name = 'calls')
        @histogram = Histogram.new(Histogram::TYPE_BIASED)
        @meter = Meter.new(name)
        clear()
      end
      
      def count
        @histogram.count
      end
      
      [:fifteen_minutes_rate, :five_minutes_rate, :mean_rate, :one_minute_rate].each do |attr_name|
        define_method(attr_name) do
          @meter.send(attr_name)
        end
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
          @meter.mark()
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
      
      
      
      
      def name
        @meter.name
      end
      
    end
  end
end
