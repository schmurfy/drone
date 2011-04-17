require File.expand_path('../../utils/uniform_sample', __FILE__)
require File.expand_path('../../utils/exponentially_decaying_sample', __FILE__)

module Drone
  class Histogram
    TYPE_UNIFORM  = lambda{ UniformSample.new(1028) }
    TYPE_BIASED   = lambda{ ExponentiallyDecayingSample.new(1028, 0.015) }
    
    MIN = (-(2**63)).freeze
    MAX = ((2**64) - 1).freeze
    
    def initialize(sample_or_type = TYPE_UNIFORM)
      if sample_or_type.is_a?(Proc)
        @sample = sample_or_type.call()
      else
        @sample = sample_or_type
      end
      
      clear()
    end
    
    def clear
      @sample.clear()
      @count = 0
      @_min = MAX
      @_max = MIN
      @_sum = 0
      @varianceM = -1
      @varianceS = 0
    end
    
    def update(val)
      @count += 1
      @sample.update(val)
      set_max(val);
      set_min(val);
      @_sum += val
      update_variance(val)
    end
    
    def count
      @count
    end
    
    def max
      (@count > 0) ? @_max : 0.0
    end
    
    def min
      (@count > 0) ? @_min : 0.0
    end
    
    def mean
      (@count > 0) ? @_sum.to_f / @count : 0.0
    end
    
    def stdDev
      (@count > 0) ? Math.sqrt( variance() ) : 0.0
    end
    
    def percentiles(*percentiles)
      scores = Array.new(percentiles.size, 0)
      if @count > 0
        values = @sample.values.sort
        percentiles.each.with_index do |p, i|
          pos = p * (values.size + 1)
          if pos < 1
            scores[i] = values[0]
          elsif pos >= values.size
            scores[i] = values[-1]
          else
            lower = values[pos - 1]
            upper = values[pos]
            scores[i] = lower + (pos - pos.floor) * (upper - lower)
          end
        end
      end
      
      scores
    end
    
    def values
      @sample.values
    end
    
  private
  
    def doubleToLongBits(n)      
      [n].pack('D').unpack('q')[0]
    end
    
    def longBitsToDouble(n)
      [n].pack('q').unpack('D')[0]
    end
    
    def update_variance(val)
      if @varianceM == -1
        @varianceM = doubleToLongBits(val)
      else
        oldMCas = @varianceM
        oldM = longBitsToDouble(oldMCas)
        newM = oldM + ((val - oldM) / count())
        
        oldSCas = @varianceS
        oldS = longBitsToDouble(oldSCas)
        newS = oldS + ((val - oldM) * (val - newM))
        
        @varianceM = doubleToLongBits(newM)
        @varianceS = doubleToLongBits(newS)
      end
    end
    
    def variance
      if @count <= 1
        0.0
      else
        longBitsToDouble(@varianceS) / (count() - 1)
      end
    end
    
    def set_max(val)
      (@_max >= val) || @_max = val
    end
    
    def set_min(val)
      (@_min <= val) || @_min = val
    end
    
    
    
  end
end
