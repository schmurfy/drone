require 'eventmachine'

module Drone
  module Schedulers
    module EMScheduler
      
      @started = false
      @timers_once = []
      @timers_periodic = []
      
      ##
      # Schedule a block to be called immediatly and after
      # that at a specified interval
      # 
      # @param [Number] delay the interval
      # 
      def self.schedule_periodic(delay, &block)
        raise "Block required" unless block
        if @started
          block.call()
          EM::add_periodic_timer(delay, &block)
        else
          @timers_periodic << [delay, block]
        end
      end
      
      
      ##
      # Schedule a block to be called after a specified
      # delay
      # 
      # @param [Number] delay the interval
      # 
      def self.schedule_once(delay, &block)
        raise "Block required" unless block
        if @started
          EM::add_timer(delay, &block)
        else
          @timers_once << [delay, block]
        end
      end
      
      
      ##
      # Start the timers.
      # 
      def self.start
        @started = true
        @timers_once.each do |(delay, block)|
          schedule_once(delay, &block)
        end
        
        @timers_periodic.each do |(delay, block)|
          schedule_periodic(delay, &block)
        end
        
      end
      
    end
  end
end
