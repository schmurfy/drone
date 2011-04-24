module Drone
  module Storage
    
    ##
    # Represents a number but procide a specific api
    # allowing this number to shared anywhere
    # 
    class SharedNumber
      ##
      # Constructor
      # 
      # @param [Number] initial_value The initial value
      # 
      def initialize(initial_value)
        raise "needs to be redefined"
      end
      
      ##
      # Increment the value
      # 
      # @param [Number] n Increment by n
      # 
      def inc(n = 1)
        raise "needs to be redefined"
      end
      
      ##
      # Decrement the value
      # 
      # @param [Number] n Decrement by n
      # 
      def dec(n = 1)
        raise "needs to be redefined"
      end
      
      ##
      # Set the value
      # 
      # @param [Number] n The new value
      # 
      def set(n)
        raise "needs to be redefined"
      end
      
      ##
      # Get the current value
      # 
      # @return [Number] The current value
      # 
      def get
        raise "needs to be redefined"
      end
      
      ##
      # Set a new value and return the old one
      # 
      # @param [Number] n The new value
      # 
      # @return [Number] The old value
      # 
      def get_and_set(n)
        raise "needs to be redefined"
      end
      
      ##
      # Set the new value but only if the current value
      # is equal to expected.
      # 
      # @param [Number] expected The expected current value
      # @param [Number] new_value The new value
      # 
      def compare_and_set(expected, new_value)
        raise "needs to be redefined"
      end
      
    end
    
    class Base
      
      ##
      # Request a fixed size array.
      # 
      # @param [String] id Any string which makes sense in the context
      # @param [Number] size The Array size
      # @param [Number] initial_value The default value for the cells
      # 
      # @return [Object] Returns an object which share the same external interface as
      #   the Array class
      # 
      def request_fixed_size_array(id, size, initial_value = nil)
        raise "needs to be redefined"
      end
      
      ##
      # Request a hash.
      # 
      # @param [String] id Any string which makes sense in the context
      # 
      # @return [Object] Returns an object which share the same external interface as
      #   the Hash class
      # 
      def request_hash(id)
        raise "needs to be redefined"
      end
      
      ##
      # Request a number "slot".
      # 
      # @param [String] id Any string which makes sense in the context
      # @param [Number] initial_value The intial value
      # 
      # @return [SharedNumber] An intance of a class inheriting SharedNumber
      # 
      # @see SharedNumber
      # 
      def request_number(id, initial_value = 0)
        raise "needs to be redefined"
      end
    end
    
  end
end
