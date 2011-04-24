require File.expand_path('../../core', __FILE__)

module Drone
  class EWMA
    M1_ALPHA  = (1 - Math.exp(-5 / 60.0)).freeze
    M5_ALPHA  = (1 - Math.exp(-5 / 60.0 / 5)).freeze
    M15_ALPHA = (1 - Math.exp(-5 / 60.0 / 15)).freeze
  
    def self.one_minute_ewma(id)
      new(id, M1_ALPHA, 5000)
    end
  
    def self.five_minutes_ewma(id)
      new(id, M5_ALPHA, 5000)
    end
  
    def self.fifteen_minutes_ewma(id)
      new(id, M15_ALPHA, 5000)
    end
  
  
    # interval: in ms
    def initialize(name, alpha, interval)
      @alpha = alpha
      @interval = interval.to_f # * (1000*1000)
      @uncounted = Drone::request_number("#{name}:uncounted", 0)
      @rate = Drone::request_number("#{name}:rate", nil)
    end
  
    def update(n)
      @uncounted.inc(n)
    end
  
    def tick()
      count = @uncounted.get_and_set(0)
      
      instant_rate = count / @interval
      rate = @rate.get
      
      if rate
        @rate.inc( @alpha * (instant_rate - rate) )
      else
        @rate.set( instant_rate )
      end
    end
  
    def rate(as = :seconds)
      case as
      when :ms        then  @rate.get
      when :seconds   then  @rate.get * 1000
      end
    end
  
  end
end
