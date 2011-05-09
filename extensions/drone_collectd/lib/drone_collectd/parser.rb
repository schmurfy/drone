module DroneCollectd
  class CollectdPacket
    # part type
    HOST            = 0x0000
    TIME            = 0x0001
    PLUGIN          = 0x0002
    PLUGIN_INSTANCE = 0x0003
    TYPE            = 0x0004
    TYPE_INSTANCE   = 0x0005
    VALUES          = 0x0006
    INTERVAL        = 0x0007
    MESSAGE         = 0x0100
    SEVERITY        = 0x0101
    
    # data type
    COUNTER   = 0
    GAUGE     = 1
    DERIVE    = 2
    ABSOLUTE  = 3
    
    
    attr_accessor :host, :time, :interval
    attr_accessor :plugin, :plugin_instance
    attr_accessor :type, :type_instance
    
    def initialize
      @values = []
      @values_type = []
    end
    
    def add_value(type, value)
      raise(ArgumentError, "unknown type: #{type}") unless CollectdPacket::const_defined?(type.to_s.upcase)
      data_type = CollectdPacket::const_get(type.to_s.upcase)
      
      @values_type << data_type
      @values << value
    end
    
    def build_packet
      @pkt =  CollectdGenerator::string(HOST, @host)
      @pkt << CollectdGenerator::number(TIME, @time)
      @pkt << CollectdGenerator::number(INTERVAL, @interval)
      @pkt << CollectdGenerator::string(PLUGIN, @plugin)
      @pkt << CollectdGenerator::string(PLUGIN_INSTANCE, @plugin_instance)
      @pkt << CollectdGenerator::string(TYPE, @type)
      @pkt << CollectdGenerator::string(TYPE_INSTANCE, @type_instance)
      
      # values part header
      @pkt << [VALUES, 4 + 2 + (@values.size * 9), @values.size].pack('nnn')
      # types
      @pkt << @values_type.pack('C*')
      
      # and the values
      @values.each.with_index do |v, i|
        case @values_type[i]
        when COUNTER, ABSOLUTE, DERIVE
          @pkt << [v >> 32, v & 0xffffffff].pack("NN")
          
        when GAUGE
          @pkt << [v].pack('E')
          
        else
          raise "unknown type: #{@values_type[i]}"
        end
      end
      
      @pkt
    end
      
  end
  
  module CollectdGenerator
    # Encode a string (type 0, null terminated string)
    def self.string(type, str)
      str += "\000"
      str_size = str.respond_to?(:bytesize) ? str.bytesize : str.size
      [type, 4 + str_size].pack("nn") + str
    end
    
    # Encode an integer
    def self.number(type, num)
      [type, 12].pack("nn") + [num >> 32, num & 0xffffffff].pack("NN")
    end
  end
  
end
