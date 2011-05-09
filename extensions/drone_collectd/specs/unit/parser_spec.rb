require File.expand_path('../../common', __FILE__)

require 'drone_collectd/parser'
include DroneCollectd

describe 'Packet Parser' do
  before do
    @packet = CollectdPacket.new()
    
    @packet.host = "localhost"
    @packet.time = 1
    @packet.interval = 10
    @packet.plugin = "plugin"
    @packet.plugin_instance = "plugin_instance"
    @packet.type = "type"
    @packet.type_instance = "type_instance"
    @packet.add_value(:counter, 42)
  end
  
  it 'can generate a packet' do
    expected = [
        "\x00\x00\x00\x0elocalhost\x00",                    # host
        "\x00\x01\x00\x0c\x00\x00\x00\x00\x00\x00\x00\x01", # time
        "\x00\x07\x00\x0c\x00\x00\x00\x00\x00\x00\x00\x0a", # interval
        "\x00\x02\x00\x0bplugin\x00",                       # plugin
        "\x00\x03\x00\x14plugin_instance\x00",              # plugin_instance
        "\x00\x04\x00\x09type\x00",                         # type
        "\x00\x05\x00\x12type_instance\x00",                # type_instance
        "\x00\x06\x00\x0f\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x2a"  # value
        
      ]
    
    if "".respond_to?(:encode)
      expected = expected.map{|s| s.encode('ASCII') }
    end
    
    data = @packet.build_packet
    
    data[0,14].should == expected[0]
    data[14,12].should == expected[1]
    data[26,12].should == expected[2]
    data[38,11].should == expected[3]
    data[49,20].should == expected[4]
    data[69, 9].should == expected[5]
    data[78,18].should == expected[6]
    data[96,15].should == expected[7]
  end
  
end
