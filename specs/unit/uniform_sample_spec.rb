require File.expand_path('../../common', __FILE__)

require 'drone/utils/uniform_sample'
include Drone

describe 'EWMA' do
  describe "A sample of 100 out of 1000 elements" do
    before do
      Drone::init_drone()
      
      @population = (0...1000)
      @sample = UniformSample.new('id1', 100)
      @population.step(1){|n| @sample.update(n) }
    end

    should "have 100 elements" do
      @sample.size.should == 100
      @sample.values.size.should == 100
    end

    should "only have elements from the population" do
      arr = @sample.values - @population.to_a
      arr.should == []
    end
  end
  
  describe "A sample of 100 out of 10 elements" do
    before do
      @population = (0...10)
      @sample = UniformSample.new('id1', 100)
      @population.step(1){|n| @sample.update(n) }
    end

    should "have 10 elements" do
      @sample.size.should == 10
      @sample.values.size.should == 10
    end

    should "only have elements from the population" do
      arr = @sample.values - @population.to_a
      arr.should == []
    end
  end
  
end

