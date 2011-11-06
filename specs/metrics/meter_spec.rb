require File.expand_path('../../common', __FILE__)

require 'drone/metrics/meter'

include Drone

EM.describe 'Meter Metrics' do
  before do
    Drone::init_drone()
    Drone::start_monitoring()
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
    
    should "have a mean rate of zero" do
      @meter.mean_rate.should.be.close?(0, 0.001)
      done
    end
    
    should "have a one-minute rate of zero" do
      @meter.one_minute_rate.should.be.close?(0, 0.001)
      done
    end
    
    should "have a five-minute rate of zero" do
      @meter.five_minutes_rate.should.be.close?(0, 0.001)
      done
    end
    
    should "have a fifteen-minute rate of zero" do
      @meter.fifteen_minutes_rate.should.be.close?(0, 0.001)
      done
    end
  end

  describe "A meter metric with three events" do
    before do
      Delorean.time_travel_to("2 second ago") do
        @meter = Metrics::Meter.new("thangs")
        @meter.mark(3)
      end
    end

    should "have a count of three" do
      @meter.count.should == 3
      done
    end
    
    should "have a mean rate of 0 events/sec" do
      @meter.mean_rate.should.be.close?(1.5, 0.01)
      done
    end
    
  end
  
end
