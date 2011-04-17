
class ExponentiallyDecayingSample
  # 1 hour in ms
  RESCALE_THRESHOLD = (1 * 60 * 60 * 1000).freeze
  
  def initialize(reservoir_size, alpha)
    @values = {}
    @alpha = alpha
    @reservoir_size = reservoir_size
    clear()
  end
  
  def clear
    @values.clear()
    @count = 0
    @start_time = Time.now
    @next_scale_time = current_time() + RESCALE_THRESHOLD
  end
  
  def size
    (@values.size < @count) ? @values.size : @count
  end
  
  
  def update(val, time = Time.now)
    priority = weight(time - @start_time) / rand()
    @count += 1
    if @count <= @reservoir_size
      @values[priority] = val
    else
      first = @values.keys.min
      if first < priority
        @values[priority] = val
        while @values.delete(first) == nil
          first = @values.keys.min
        end
      end
    end
    
    now = current_time()
    if now >= @next_scale_time
      rescale(now, @next_scale_time)
    end
  end
  
  def values
    @values.values
  end
  
  def rescale(now)
    @next_scale_time = current_time() + RESCALE_THRESHOLD
    old_start = @start_time
    @start_time = Time.now
    
    @values = Hash[ @values.map{ |k,v|
        [k * Math.exp(-@alpha * (@start_time - old_start)), v]
      }]
    
  end
  
private
  
  def current_time
    Time.now.to_f * 1000
  end
  
  def weight(n)
    Math.exp(@alpha * n)
  end
  
end
