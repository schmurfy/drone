require File.expand_path('../../core', __FILE__)

module Drone
  class ExponentiallyDecayingSample
    # 1 hour in ms
    RESCALE_THRESHOLD = (1 * 60 * 60 * 1000).freeze
  
    def initialize(id, reservoir_size, alpha)
      @id = id
      @values = Drone::request_hash("#{@id}:values")
      @count = Drone::request_number("#{@id}:count", 0)
      @start_time = Drone::request_number("#{@id}:start_time", current_time())
      @next_scale_time = Drone::request_number("#{@id}:next_scale_time", current_time() + RESCALE_THRESHOLD)
      
      @alpha = alpha
      @reservoir_size = reservoir_size
    end
  
    def clear
      @values.clear()
      @count.set(0)
      @start_time.set(current_time())
      @next_scale_time.set( current_time() + RESCALE_THRESHOLD )
    end
  
    def size
      count =  @count.get
      (@values.size < count) ? @values.size : count
    end
  
  
    def update(val, time = current_time)
      priority = weight(time - @start_time.get) / generate_random()
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
      next_scale = @next_scale_time.get
      if now >= next_scale
        rescale(now, next_scale)
      end
    end
  
    def values
      @values.keys.sort.inject([]) do |buff, key|
        buff << @values[key]
      end
    end
  
    def rescale(now, next_scale)
      if @next_scale_time.compare_and_set(next_scale, now + RESCALE_THRESHOLD)
        new_start = current_time()
        old_start = @start_time.get_and_set( new_start )
        
        @values = Hash[ @values.map{ |k,v|
            [k * Math.exp(-@alpha * (new_start - old_start)), v]
          }]
      end
    end
  
  private
    
    ##
    # Generates a non-zero random number
    # According to the ruby documentation rand() can return 0
    # so we ensure this will never happen
    # 
    # @return [Float] The random number
    # 
    def generate_random()
      begin
        r = Kernel.rand()
      end while r == 0.0
    
      r
    end
  
    def current_time
      Time.now.to_f * 1000
    end
  
    def weight(n)
      Math.exp(@alpha * n)
    end
  
  end
end
