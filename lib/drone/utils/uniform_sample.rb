require File.expand_path('../../core', __FILE__)

module Drone
  class UniformSample
    
    ##
    # Create a new instance.
    # 
    # @param [String] id A string which will be used by distributed
    #   storage backend to use the same value for all instances with
    #   the same id
    # @param [Number] size The size of the requested array
    # 
    def initialize(id, size)
      @id = id
      @values = Drone::request_fixed_size_array("#{id}:values", size, 0)
      @count = Drone::request_number("#{id}:count", 0)
    end
  
    # def clear
    #   @values.size.times do |n|
    #     @values[n] = 0
    #   end
    # 
    #   @count.set(0)
    # end
  
    def size
      c = @count.get
      (c > @values.size) ? @values.size : c
    end
  
    def update(val)
      @count.inc
      count = @count.get
      if count <= @values.size
        @values[count - 1] = val
      else
        r = rand(2**64 - 1) % count
        if r < @values.size
          @values[r] = val
        end
      end
    end
  
    def values
      # only return @count elements
      @values[0,@count.get]
    end
  
  end
end
