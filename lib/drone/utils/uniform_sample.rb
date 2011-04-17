class UniformSample
  
  def initialize(size)
    @values = Array.new(size)
    clear()
  end
  
  def clear
    @values.size.times do |n|
      @values[n] = 0
    end
    
    @count = 0
  end
  
  def size
    (@count > @values.size) ? @values.size : @count
  end
  
  def update(val)
    @count += 1
    if @count <= @values.size
      @values[@count - 1] = val
    else
      r = rand(2**64 - 1) % @count
      if r < @values.size
        @values[r] = val
      end
    end
  end
  
  def values
    # only return @count elements
    @values[0,@count]
  end
  
end
