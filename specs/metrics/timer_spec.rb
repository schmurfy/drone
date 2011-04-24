require File.expand_path('../../common', __FILE__)

require 'drone/metrics/timer'
include Drone

EM.describe 'Timer Metrics' do
  before do
    Drone::init_drone()
    Drone::start_monitoring()
  end
  
  describe "A blank timer" do
    before do
      @timer = Metrics::Timer.new('id')
    end

    should "have a max of zero" do
      @timer.max.should.be.close?(0, 0.001)
      done
    end

    should "have a min of zero" do
      @timer.min.should.be.close?(0, 0.001)
      done
    end

    should "have a mean of zero" do
      @timer.mean.should.be.close?(0, 0.001)
      done
    end

    should "have a count of zero" do
      @timer.count.should == 0
      done
    end

    should "have a standard deviation of zero" do
      @timer.stdDev.should.be.close?(0, 0.001)
      done
    end

    should "have a median/p95/p98/p99/p999 of zero" do
      median, p95, p98, p99, p999 = @timer.percentiles(0.5, 0.95, 0.98, 0.99, 0.999)
      median.should.be.close?(0, 0.001)
      p95.should.be.close?(0, 0.001)
      p98.should.be.close?(0, 0.001)
      p99.should.be.close?(0, 0.001)
      p999.should.be.close?(0, 0.001)
      done
    end
    
    should "have no values" do
      @timer.values.should == []
      done
    end
  end
  
  
  
  describe "Timing a series of events" do
    before do
      @timer = Metrics::Timer.new('id')
      @timer.update(10)
      @timer.update(20)
      @timer.update(20)
      @timer.update(30)
      @timer.update(40)
    end

    should "record the count" do
      @timer.count.should == 5
      done
    end

    should "calculate the minimum duration" do
      @timer.min.should.be.close?(10, 0.001)
      done
    end

    should "calclate the maximum duration" do
      @timer.max.should.be.close?(40, 0.001)
      done
    end

    should "calclate the mean duration" do
      @timer.mean.should.be.close?(24, 0.001)
      done
    end

    should "calclate the standard deviation" do
      @timer.stdDev.should.be.close?(11.401, 0.001)
      done
    end

    should "calculate the median/p95/p98/p99/p999" do
      median, p95, p98, p99, p999 = @timer.percentiles(0.5, 0.95, 0.98, 0.99, 0.999)
      median.should.be.close?(20, 0.001)
      p95.should.be.close?(40, 0.001)
      p98.should.be.close?(40, 0.001)
      p99.should.be.close?(40, 0.001)
      p999.should.be.close?(40, 0.001)
      done
    end

    should "have a series of values" do
      @timer.values.sort.should == [10, 20, 20, 30, 40]
      done
    end
  end
  
end
