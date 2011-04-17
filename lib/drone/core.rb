
require File.expand_path('../schedulers/eventmachine', __FILE__)

module Drone
  ##
  # This module contains all the metrics you can use to collect data
  # 
  module Metrics; end
  
  
  ##
  # This module contains all the interfaces to the outside world,
  # they are the only way to communicate with external applications
  # 
  module Interface; end
  
  
  ##
  # This module contains the class used for scheduling timers
  # 
  module Schedulers; end
  
  class <<self
    
    def init_drone(scheduler = Schedulers::EMScheduler)
      @meters = []
      @scheduler = scheduler
      @monitored_classes = []
      @output_modules = []
    end
    
    ##
    # Start monitoring.
    # This method needs to be called when the timers can be started
    # In the case of eventmachine scheduler it needs to be called
    # in the EM::run block
    # 
    def start_monitoring
      @scheduler.start()
    end
    
    def each_metric
      raise "Block expected" unless block_given?
      @meters.each{|m| yield(m) }
    end
    
    
    ##
    # Fetch a metric by its name
    # 
    # @param [String] name The mtric's name
    # 
    def find_metric(name)
      @meters.detect{|m| m.name == name }
    end
    
    ##
    # Instantiate an output module.
    # 
    # @param [String,Symbol] type Class name in lowercase
    # @param [Array] args additional parameters will be sent to thh
    #   class constructor
    # 
    def add_output(type, *args)
      class_name = type.to_s.capitalize
      klass = Drone::Interfaces.const_get(class_name)
      @output_modules << klass.new(*args)
    end
    
    ##
    # Register a monitored class.
    # @private
    # 
    def register_monitored_class(klass)
      @monitored_classes << klass
    end
    
    ##
    # Register a new counter
    # @param [String] type Name of this metric
    # @api public
    # 
    def register_counter(type)
      register_meter( Drone::Metrics::Counter.new(type) )
    end
    
    ##
    # Register a new gauge
    # @param [String] type Name of this metric
    # @api public
    # 
    def register_gauge(type, &block)
      register_meter( Drone::Metrics::Gauge.new(type, &block) )
    end
    
    ##
    # Register a new meter
    # This method can be used bu the user but the prefered
    # way is to use the register_counter / register_gauge methods
    # 
    # @param [Meter] meter The Meter to register
    # @api private
    # @private
    # 
    def register_meter(meter)
      @meters << meter
      meter
    end
    
    ##
    # (see EMScheduler#schedule_periodic)
    # 
    def schedule_periodic(*args, &block)
      @scheduler.schedule_periodic(*args, &block)
    end
    
    ##
    # (see EMScheduler#schedule_once)
    # 
    def schedule_once(*args, &block)
      @scheduler.schedule_once(*args, &block)
    end
    
  end
end
