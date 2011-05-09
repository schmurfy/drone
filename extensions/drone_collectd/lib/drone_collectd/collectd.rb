require File.expand_path('../parser', __FILE__)

module Drone
  module Interfaces
    
    ##
    # Send data to collectd periodically, this interface except
    # a specific format for the metric names which is:
    # 
    # plugin[:plugin_instance]/type[:type_instance]
    # the simplest form being:
    # plugin/type
    # 
    class Collectd < Base
      
      # 1.9 only ...
      # NAME_FORMAT = %r{(?<plugin>\w+)(:(?<plugin_instance>\w+))?/(?<type>\w+)(:(?<type_instance>\w+))?}
      
      NAME_FORMAT = %r{(\w+)(?::(\w+))?/(\w+)(?::(\w+))?}
      
      ##
      # Instantiate a collectd interface
      # 
      # @param [Numeric] period the period passed to the Base class
      # @param [String] hostname the hostname to use for collectd
      # @param [String] address the address where the collectd daemon is listening
      # @param [Numeric] port The collectd daemon port
      # 
      def initialize(period, args = {})        
        super(period)
        @hostname = args.delete(:hostname)
        @address = args.delete(:address) || '127.0.0.1'
        @port = args.delete(:port) || 25826
        @reported_percentiles = args.delete(:percentiles)
        @socket = EM::open_datagram_socket('0.0.0.0', nil)
        
        unless args.empty?
          raise ArgumentError, "unknown keys: #{args.keys}"
        end
      end
      
      def output
        
        Drone::each_metric do |m|
          # parse the name
          if NAME_FORMAT.match(m.name)
            # build the packet
            data = DroneCollectd::CollectdPacket.new
            data.host = @hostname
            data.time = Time.now.to_i
            data.interval = @period
            data.plugin = $1.to_s
            data.plugin_instance = $2.to_s
            data.type = $3.to_s
            data.type_instance = $4.to_s
            
            case m
            when Metrics::Counter
              data.add_value(:counter, m.value )
              
            when Metrics::Gauge
              data.add_value(:gauge, m.value )
              
            when Metrics::Meter
              # mean:GAUGE:U:U, rate1:GAUGE:U:U, rate5:GAUGE:U:U, rate15:GAUGE:U:U
              data.add_value(:gauge, m.mean_rate )
              data.add_value(:gauge, m.one_minute_rate )
              data.add_value(:gauge, m.five_minutes_rate )
              data.add_value(:gauge, m.fifteen_minutes_rate )
            
            when Metrics::Timer
              # min:GAUGE:0:U,  max:GAUGE:0:U,  mean:GAUGE:0:U, stddev:GAUGE:U:U, median:GAUGE:0:U, p75:GAUGE:0:U, p95:GAUGE:0:U
              data.add_value(:gauge, m.min )
              data.add_value(:gauge, m.max )
              data.add_value(:gauge, m.mean )
              data.add_value(:gauge, m.stdDev )
              
              percs = m.percentiles( *@reported_percentiles )
              percs.each do |p|
                data.add_value(:gauge, p )
              end
            
            end
            
            # and send it
            @socket.send_datagram(data.build_packet, @address, @port)
          else
            puts "Metric with incorrect name ignored: #{m.name}"
          end
        end
        
      end
      
    end
    
  end
end
