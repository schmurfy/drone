require File.expand_path('../../common', __FILE__)

require 'drone/metrics/histogram'

include Drone

describe 'Histogram' do
  before do
    Drone::init_drone()
  end
  
  describe "A histogram with zero recorded valeus" do
    before do
      @histogram = Histogram.new("id1", UniformSample.new("id1:sample", 100))
    end

    should "have a count of 0" do
      @histogram.count.should == 0
    end

    should "have a max of 0" do
      @histogram.max.should == 0
    end

    should "have a min of 0" do
      @histogram.min.should == 0
    end

    should "have a mean of 0" do
      @histogram.mean.should == 0.0
    end

    should "have a standard deviation of 0" do
      @histogram.stdDev.should == 0
    end

    should "calculate percentiles" do
      percentiles = @histogram.percentiles(0.5, 0.75, 0.99)
    
      percentiles[0].should.be.close?(0, 0.01)
      percentiles[1].should.be.close?(0, 0.01)
      percentiles[2].should.be.close?(0, 0.01)
    end
    
    should "have no values" do
      @histogram.values.should == []
    end
  end
  
  
  describe "A histogram of the numbers 1 through 10000" do
    before do
      @histogram = Histogram.new("id1", UniformSample.new("id1:sample", 100000) )
      (1..10000).each{|n| @histogram.update(n) }
    end

    should "have a count of 10000" do
      @histogram.count.should == 10000
    end

    should "have a max value of 10000" do
      @histogram.max.should == 10000
    end

    should "have a min value of 1" do
      @histogram.min.should == 1
    end

    should "have a mean value of 5000.5" do
      @histogram.mean.should.be.close?(5000.5, 0.01)
    end

    should "have a standard deviation of X" do
      @histogram.stdDev.should.be.close?(2886.89, 0.1)
    end

    should "calculate percentiles" do
      percentiles = @histogram.percentiles(0.5, 0.75, 0.99)

      percentiles[0].should.be.close?(5000.5, 0.01)
      percentiles[1].should.be.close?(7500.75, 0.01)
      percentiles[2].should.be.close?(9900.99, 0.01)
    end

    should "have 10000 values" do
      @histogram.values.should == (1..10000).to_a
      # histogram.values.toList must beEqualTo((1 to 10000).toList)
    end
  end
  
end
