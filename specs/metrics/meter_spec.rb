require File.expand_path('../../common', __FILE__)

require 'drone/metrics/meter'

include Drone

EM.describe 'Meter Metrics' do
  before do
    Drone::init_drone()
  end
  
  describe "A meter metric with no events" do
    before do
      @meter = Metrics::Meter.new("thangs")
    end

    should "have a count of zero" do
      @meter.count.should == 0
      done
    end

    should "have a mean rate of 0 events/sec" do
      @meter.mean_rate.should == 0.0
      done
    end
  end

  describe "A meter metric with three events" do
    before do
      @meter = Metrics::Meter.new("thangs")
      @meter.mark(3)
    end

    should "have a count of three" do
      @meter.count.should == 3
      done
    end
  end
  
end
