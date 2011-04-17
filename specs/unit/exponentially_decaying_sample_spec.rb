require File.expand_path('../../common', __FILE__)

require 'drone/utils/exponentially_decaying_sample'

describe 'Exponentially Decaying Sample' do
  describe "A sample of 100 out of 1000 elements" do
    before do
      @population = (0...100)
      @sample = ExponentiallyDecayingSample.new(1000, 0.99)
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
      @sample = ExponentiallyDecayingSample.new(100, 0.99)
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
  
  
  describe "A heavily-biased sample of 100 out of 1000 elements" do
    before do
      @population = (0...100)
      @sample = ExponentiallyDecayingSample.new(1000, 0.99)
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
    
    should "rescale after 1 hour" do
      @sample.expects(:rescale)
      
      Delorean.time_travel_to("2 hours from now") do
        @sample.update(1)
      end
      
      @sample.size.should == 101
      @sample.values.size.should == 101
    end
    
    it 'can rescale' do
      @sample.rescale(Time.now)
      @sample.values.should.not == []
      # TODO: add a real test here, for now it only tests
      # that the code actually runs
    end
  end
  
end
