require File.expand_path('../base', __FILE__)

module Drone
  module Storage
    
    class Memory < Base
      
      class MemorySharedNumber
        def initialize(initial_value)
          @store = initial_value
        end
        
        def inc(n = 1)
          @store += n
        end
        
        def dec(n = 1)
          @store -= n
        end
        
        def set(n)
          @store = n
        end
        
        def get
          @store
        end
        
        def get_and_set(n)
          ret = @store
          set(n)
          ret
        end
        
        def compare_and_set(expected, new_value)
          # dummy implementation, with memory storage nothing can
          # happen to our data
          set(new_value)
          true
        end
        
      end
      
      def request_fixed_size_array(id, size, initial_value = nil)
        Array.new(size, initial_value)
      end
      
      def request_hash(id)
        Hash.new
      end
      
      def request_number(id, initial_value = 0)
        MemorySharedNumber.new(initial_value)
      end
      
    end
    
  end
end
