require 'eventmachine'

require File.expand_path('../metric', __FILE__)
require File.expand_path('../../core', __FILE__)
require File.expand_path('../../utils/ewma', __FILE__)

module Drone
  module Metrics
    ##
    # A meter measures mean throughput and one-, five-, and
    # fifteen-minute exponentially-weighted moving average throughputs.
    # 
    class Meter < Metric
      INTERVAL = 5
      
      attr_reader :count
      
      def initialize(name)
        super(name)
        @start_time = Time.now
        @count = 0
        @rates = {
          1   => EWMA.one_minute_ewma,
          5   => EWMA.five_minutes_ewma,
          15  => EWMA.fifteen_minutes_ewma
        }
        
        Drone::schedule_periodic(INTERVAL){ tick() }
      end

      def tick
        @rates.values.each(&:tick)
      end

      def mark(events = 1)
        @count += events
        @rates.each do |_, r|
          r.update(events)
        end
      end

      def mean_rate
        if @count == 0
          0.0
        else
          @count / (Time.now.to_f - @start_time.to_f)
        end
      end

      def one_minute_rate
        @rates[1].rate()
      end

      def five_minutes_rate
        @rates[5].rate()
      end

      def fifteen_minutes_rate
        @rates[15].rate()
      end
      
    end
  end
end
