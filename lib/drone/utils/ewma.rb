# ruby adaptation of the metrics library version by Coda Hale
class EWMA
  M1_ALPHA  = (1 - Math.exp(-5 / 60.0)).freeze
  M5_ALPHA  = (1 - Math.exp(-5 / 60.0 / 5)).freeze
  M15_ALPHA = (1 - Math.exp(-5 / 60.0 / 15)).freeze
  
  def self.one_minute_ewma
    new(M1_ALPHA, 5000)
  end
  
  def self.five_minutes_ewma
    new(M5_ALPHA, 5000)
  end
  
  def self.fifteen_minutes_ewma
    new(M15_ALPHA, 5000)
  end
  
  
  # interval: in ms
  def initialize(alpha, interval)
    @alpha = alpha
    @interval = interval.to_f # * (1000*1000)
    @uncounted = 0
    @rate = nil
  end
  
  def update(n)
    @uncounted += n
  end
  
  def tick()
    count = @uncounted
    @uncounted = 0
    instant_rate = count / @interval
    if @rate
      @rate += (@alpha * (instant_rate - @rate))
    else
      @rate = instant_rate
    end
  end
  
  def rate(as = :seconds)
    case as
    when :ms        then  @rate
    when :seconds   then  @rate * 1000
    end
  end
  
end
