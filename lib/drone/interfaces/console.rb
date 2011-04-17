require File.expand_path('../base', __FILE__)

module Drone
  module Interfaces
    ##
    # This interface is meant for debug mainly, it will
    # simply output all the available metrics at a regular
    # interval on the console.
    # 
    # @example
    #   require 'drone'
    #   Drone::init_drone()
    #   Drone::add_output(:console, 1)
    #
    class Console < Base
            
      def output()
        puts ""
        puts "[#{Time.now.strftime('%M:%S')}] Drone report:"
        Drone::each_metric do |m|
          case m
          when Metrics::Gauge
            puts "[Gauge] #{m.name} : #{m.value}"
            
          when Metrics::Counter
            puts "[Counter] #{m.name} : #{m.value}"
            
          when Metrics::Timer
            puts "[Timer] #{m.name}"
            print_meter(m)
            print_histogram(m)
            
          when Metrics::Meter
            puts "[Meter] #{m.name}"
            print_meter(m)
          
          when Metrics::Histogram
            puts "[Histogram] #{m.name}"
            print_histogram(m)
            
          else
            puts "Unknown metric: #{m}"
          end
        end
      end
      
      
    private
      def print_meter(m)
        puts format("%20s : %d", "count", m.count)
        
        {
          'mean rate'     => m.mean_rate,
          '1-minute rate' => m.one_minute_rate,
          '5-minute rate' => m.five_minutes_rate,
          '15-minute rate' => m.fifteen_minutes_rate
        }.each do |label, value|
          puts format("%20s : %2.2f", label, value)
        end
      end
      
      def print_histogram(m)
        percentiles = m.percentiles(0.5, 0.75, 0.95, 0.98, 0.99, 0.999)
        {
          'min'     => m.min,
          'max'     => m.max,
          'mean'    => m.mean,
          'stddev'  => m.stdDev,
          'median'  => percentiles[0],
          '75%'     => percentiles[1],
          '%95'     => percentiles[2],
          '%98'     => percentiles[3],
          '%99'     => percentiles[4],
          '%99.9'   => percentiles[5]
        }.each do |label, value|
          puts format("%20s : %2.2f", label, value)
        end
      end
      
    end
    
  end
end
