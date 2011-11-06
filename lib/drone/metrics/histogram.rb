require File.expand_path('../../utils/uniform_sample', __FILE__)
require File.expand_path('../../utils/exponentially_decaying_sample', __FILE__)
require File.expand_path('../metric', __FILE__)

module Drone
  module Metrics
    ##
    # An Histogram store a list of values (1028) and can
    # compute on demand statistics on those values:
    # - min/max
    # - mean
    # - stddev
    # - percentiles
    # 
    class Histogram < Metric    
      MIN = (-(2**63)).freeze
      MAX = ((2**64) - 1).freeze
    
      def initialize(name, sample_or_type = :uniform)
        super(name)
      
        if sample_or_type.is_a?(Symbol)
          case sample_or_type
          when :uniform   then  @sample = UniformSample.new("#{name}:sample", 1028)
          when :biased    then  @sample = ExponentiallyDecayingSample.new("#{name}:sample", 1028, 0.015)
          else
            raise ArgumentError, "unknown type: #{sample_or_type}"
          end
        else
          @sample = sample_or_type
        end
      
        @count = Drone::request_number("#{name}:count", 0)
        @_min = Drone::request_number("#{name}:min", MAX)
        @_max = Drone::request_number("#{name}:max", MIN)
        @_sum = Drone::request_number("#{name}:max", 0)
        @varianceM = Drone::request_number("#{name}:varianceM", -1)
        @varianceS = Drone::request_number("#{name}:varianceS", 0)
      
      end
    
      def clear
        @sample.clear()
            
        @count = Drone::request_number("#{name}:count", 0)
        @_min = Drone::request_number("#{name}:min", MAX)
        @_max = Drone::request_number("#{name}:max", MIN)
        @_sum = Drone::request_number("#{name}:max", 0)
        @varianceM = Drone::request_number("#{name}:varianceM", -1)
        @varianceS = Drone::request_number("#{name}:varianceS", 0)
      end
    
      def update(val)
        @count.inc
        @sample.update(val)
        set_max(val);
        set_min(val);
        @_sum.inc(val)
        update_variance(val)
      end
    
      def count
        @count.get
      end
    
      def max
        (@count.get > 0) ? @_max.get : 0.0
      end
    
      def min
        (@count.get > 0) ? @_min.get : 0.0
      end
    
      def mean
        (@count.get > 0) ? @_sum.get.to_f / @count.get : 0.0
      end
    
      def stdDev
        (@count.get > 0) ? Math.sqrt( variance() ) : 0.0
      end
    
      def percentiles(*percentiles)
        scores = Array.new(percentiles.size, 0)
        if @count.get > 0
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
        if @varianceM.get == -1
          @varianceM.set( doubleToLongBits(val) )
        else
          oldMCas = @varianceM.get
          oldM = longBitsToDouble(oldMCas)
          newM = oldM + ((val - oldM) / count())
        
          oldSCas = @varianceS.get
          oldS = longBitsToDouble(oldSCas)
          newS = oldS + ((val - oldM) * (val - newM))
        
          @varianceM.set( doubleToLongBits(newM) )
          @varianceS.set( doubleToLongBits(newS) )
        end
      end
    
      def variance
        count = @count.get
        if count <= 1
          0.0
        else
          longBitsToDouble(@varianceS.get) / (count - 1)
        end
      end
    
      def set_max(val)
        (@_max.get >= val) || @_max.set(val)
      end
    
      def set_min(val)
        (@_min.get <= val) || @_min.set(val)
      end
    
    
    
    end
  end
end
