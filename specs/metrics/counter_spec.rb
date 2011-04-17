require File.expand_path('../../common', __FILE__)

require 'drone/metrics/counter'
include Drone

describe 'Counter Metrics' do
  before do
    @counter = Metrics::Counter.new('something')
  end

  should "start at zero" do
    @counter.value.should == 0
  end

  should "increment by one" do
    @counter.inc()
    @counter.value.should == 1
  end

  should "increment by an arbitrary delta" do
    @counter.inc(3)
    @counter.value.should == 3
  end

  should "decrement by one" do
    @counter.dec()
    @counter.value.should == -1
  end

  should "decrement by an arbitrary delta" do
    @counter.dec(3)
    @counter.value.should == -3
  end

  should "be zero after being cleared" do
    @counter.inc(3)
    @counter.clear()
    @counter.value.should == 0
  end
  
end
