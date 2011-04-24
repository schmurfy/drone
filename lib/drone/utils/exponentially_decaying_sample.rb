require File.expand_path('../../core', __FILE__)

module Drone
  class ExponentiallyDecayingSample
    # 1 hour in ms
    RESCALE_THRESHOLD = (1 * 60 * 60 * 1000).freeze
  
    def initialize(id, reservoir_size, alpha)
      @id = id
      @values = Drone::request_hash("#{@id}:values")
      @count = Drone::request_number("#{@id}:count", 0)
      @start_time = Drone::request_number("#{@id}:start_time", Time.now.to_f)
      @next_scale_time = Drone::request_number("#{@id}:next_scale_time", current_time() + RESCALE_THRESHOLD)
      
      @alpha = alpha
      @reservoir_size = reservoir_size
    end
  
    def clear
      @values.clear()
      @count.set(0)
      @start_time.set(Time.now.to_f)
      @next_scale_time.set( current_time() + RESCALE_THRESHOLD )
    end
  
    def size
      count =  @count.get
      (@values.size < count) ? @values.size : count
    end
  
  
    def update(val, time = Time.now.to_f)
      priority = weight(time - @start_time.get) / rand()
      count = @count.inc
      if count <= @reservoir_size
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
      if now >= @next_scale_time.get
        rescale(now)
      end
    end
  
    def values
      @values.values
    end
  
    def rescale(now)
      @next_scale_time.set( current_time() + RESCALE_THRESHOLD )
      new_start = Time.now.to_f
      old_start = @start_time.get_and_set(new_start)
    
      @values = Hash[ @values.map{ |k,v|
          [k * Math.exp(-@alpha * (new_start - old_start)), v]
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
end
