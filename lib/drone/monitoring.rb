require File.expand_path('../metrics/meter', __FILE__)
require File.expand_path('../metrics/timer', __FILE__)

module Drone
  ##
  # This module contains what is needed to instruments
  # class methods easily
  # 
  module Monitoring
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
      
      Drone::register_monitored_class(base)
    end
    
    module ClassMethods
    # external API
      
      ##
      # Monitor the call rate of the following method
      # 
      # @param [String] name metric name, it must be unique and will be shared
      #                       among all the objects of this class
      # @api public
      # 
      def monitor_rate(name)
        meter = Drone::find_metric(name) || Metrics::Meter.new(name)
        unless meter.is_a?(Metrics::Meter)
          raise(TypeError, "metric #{name} is already defined as #{rate.class}")
        end
        
        Drone::register_meter(meter)
        @_rate_waiting = meter
      end
      
      ##
      # Monitor the time of execution as well as the
      # call rate
      # 
      # @param [String] name metric name, it must be unique and will be shared
      #                       among all the objects of this class
      # 
      # @api public
      # 
      def monitor_time(name)
        timer = Drone::find_metric(name) || Metrics::Timer.new(name)
        unless timer.is_a?(Metrics::Timer)
          raise(TypeError, "metric #{name} is already defined as #{rate.class}")
        end
        Drone::register_meter(timer)
        @_timer_waiting = timer
      end
      
      
    # internals
      
      ##
      # @private
      # 
      def method_added(m)
        return if @_ignore_added
        
        @_ignore_added = true
        ma_rate_meter(m) if @_rate_waiting
        ma_timer_meter(m) if @_timer_waiting
        @_ignore_added = false
      end
      
      ##
      # @private
      # 
      def ma_rate_meter(m)
        rate = @_rate_waiting
        @_rate_waiting = nil
        
        define_method("#{m}_with_meter") do |*args, &block|
          rate.mark()
          send("#{m}_without_meter", *args, &block)
        end
        
        alias_method "#{m}_without_meter", m
        alias_method m, "#{m}_with_meter"
      end
      
      ##
      # @private
      # 
      def ma_timer_meter(m)
        timer = @_timer_waiting
        @_timer_waiting = nil
        
        define_method("#{m}_with_timer") do |*args, &block|
          timer.time do
            send("#{m}_without_timer", *args, &block)
          end
        end
        
        alias_method "#{m}_without_timer", m
        alias_method m, "#{m}_with_timer"
      end
      
    end
    
  end
end
