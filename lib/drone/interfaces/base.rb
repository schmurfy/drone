module Drone
  module Interfaces
    
    class Base
      def initialize(period)
        @period = period
        Drone::schedule_periodic(period){ output() }
      end
      
      def output
        raise "Uninmplemented"
      end
      
    end
    
  end
end
