require 'bigdecimal'
require 'bigdecimal/util'
require 'bigdecimal/math'

require File.expand_path('../../core', __FILE__)

module Drone
  
  ##
  # An exponentially-decaying random sample
  # 
  class ExponentiallyDecayingSample
    # 1 hour
    RESCALE_THRESHOLD = (1 * 60 * 60).freeze
    
    ##
    # Create a new dataset, if the decay factor is too big
    # the flt ruby library is used for internal computations
    # to allow greater precision, the performance impact should be
    # minimal.
    # 
    # @param [String] id A unique id representing this
    #   dataset.
    # @param [Integer] reservoir_size the number of samples
    #   to keep.
    # @param [Number] alpha the decay factor, the higher this
    #   number, the more biased the sample will be towards
    #   newer values.
    # 
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
      new_count = @count.inc
      
      if new_count <= @reservoir_size
        @values[priority] = val
      else
        first = @values.keys[0]
        if first < priority
          old_val, @values[priority] = @values[priority], val
          unless old_val
            while @values.delete(first) == nil
              first = @values.keys[0]
            end
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
        time_diff = new_start - old_start
        
        coeff = math_exp(-@alpha * time_diff)
        
        @values = Hash[ @values.map{ |k,v|
            [k * coeff, v]
          }]
        
      end
    end
  
  private
    
    def use_flt?
      true
    end
    
    def math_exp(n)
      if use_flt?
        BigMath.exp( BigDecimal(n.to_s), 2 )
      else
        Math.exp(n)
      end
    end
    
    ##
    # Generates a non-zero random number
    # According to the ruby documentation rand() could return 0
    # so we ensure this will never happen
    # 
    # @return [Float] The random number
    # 
    def generate_random()
      begin
        r = Kernel.rand()
      end while r == 0.0
      
      if use_flt?
        BigDecimal(r.to_s)
      else
        r
      end
    end
  
    def current_time
      Time.now.to_f
    end
  
    def weight(n)
      math_exp(@alpha * n)
    end
  
  end
end
