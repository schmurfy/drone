require 'thin'
require 'json'

Thin::Logging.silent = true

module Drone
  module Interfaces
    
    class Json < Base
      def initialize(address = '0.0.0.0', port = 3001)
        me = self
        Thin::Server.start(address, port) do
          map('/'){ run(me) }
        end
      end
      
      def call(env)
        ret = {}
        
        Drone::each_metric do |m|
          case m
          when Metrics::Gauge
            ret[m.name] = gauge_hash(m)
            
          when Metrics::Counter
            ret[m.name] = counter_hash(m)
            
          when Metrics::Timer
            tmp = {
              'type' => 'timer'
            }
            
            tmp = histogram_hash(m, tmp)
            
            ret[m.name] = tmp
            
          when Metrics::Meter
            ret[m.name] = meter_hash(m, { 'type' => 'meter' })
          
          when Metrics::Histogram
            ret[m.name] = histogram_hash(m, { 'type' => 'histogram' })
            
          else
            puts "Unknown metric: #{m}"
          end
        end
        
        
        [
          200,
          {'Content-Type' => 'application/json'},
          ret.to_json
        ]
      end
    
    private
      def gauge_hash(m)
        {
          'type'  => 'gauge',
          'value' => m.value
        }
      end
      
      def counter_hash(m)
        {
          'type'  => 'counter',
          'value' => m.value
        }
      end
      
      def meter_hash(m, h = {})
        h.merge({
          'count'     => m.count,
          'mean_rate' => m.mean_rate,
          'rate_1'    => m.one_minute_rate,
          'rate_5'    => m.five_minutes_rate,
          'rate_15'   => m.fifteen_minutes_rate
        })
      end
      
      def histogram_hash(m, h = {})
        percentiles = m.percentiles(0.5, 0.75, 0.95, 0.98, 0.99, 0.999)
        
        h.merge({
          'min'     => m.min,
          'max'     => m.max,
          'mean'    => m.mean,
          'stddev'  => m.stdDev,
          'median'  => percentiles[0],
          '75p'     => percentiles[1],
          '95p'     => percentiles[2],
          '98p'     => percentiles[3],
          '99p'     => percentiles[4],
          '999p'    => percentiles[5]
        })
      end
    end
    
  end
end
