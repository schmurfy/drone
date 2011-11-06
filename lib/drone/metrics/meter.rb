require 'eventmachine'

require File.expand_path('../metric', __FILE__)
require File.expand_path('../../core', __FILE__)
require File.expand_path('../../utils/ewma', __FILE__)

module Drone
  module Metrics
    ##
    # This meter measures mean throughput and one-, five-, and
    # fifteen-minute exponentially-weighted moving average throughputs.
    # 
    class Meter < Metric
      INTERVAL = 5
      
      def initialize(name)
        super(name)
        @start_time = Drone::request_number("#{name}:start_time", Time.now)
        @next_tick = Drone::request_number("#{name}:next_tick_lock", 1)
        
        @count = Drone::request_number("#{name}:count", 0)
        @rates = {
          1   => EWMA.one_minute_ewma("#{name}:rate1"),
          5   => EWMA.five_minutes_ewma("#{name}:rate5"),
          15  => EWMA.fifteen_minutes_ewma("#{name}:rate15")
        }
        
        Drone::schedule_periodic(INTERVAL) do
          Fiber.new{ tick() }.resume
        end
      end

      def tick
        # init if required
        @local_next_tick ||= @next_tick.get
        
        # ensure only one process will trigger the tick
        if @next_tick.compare_and_set(@local_next_tick, @local_next_tick + 1)
          @rates.values.each(&:tick)
          @local_next_tick += 1
        else
          # reset the tick counter to give a chance to this
          # process to trigger the next tick
          @local_next_tick = @next_tick.get()
        end
      end

      def mark(events = 1)
        @count.inc(events)
        @rates.each do |_, r|
          r.update(events)
        end
      end
      
      def count
        @count.get
      end

      def mean_rate
        count = @count.get
        if count == 0
          0.0
        else
          count / (Time.now.to_f - @start_time.get.to_f)
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
