require File.expand_path('../../common', __FILE__)

require 'drone/metrics/gauge'
include Drone

describe 'Geuge Metric' do
  before do
    @n = 0
    @gauge = Metrics::Gauge.new("temperature"){ @n+= 1 }
  end
  
  should 'require a block' do
    err = proc{
      Metrics::Gauge.new('dummy')
    }.should.raise(RuntimeError)
    
    err.message.should.include?('Block expected')
  end
  
  should 'call block when value is asked' do
    @n.should == 0
    @gauge.value.should == 1
    @n.should == 1
    
    @gauge.value.should == 2
  end
  
end
