require File.expand_path('../../common', __FILE__)

require 'drone/utils/exponentially_decaying_sample'
include Drone

describe 'Exponentially Decaying Sample' do
  before do
    Drone::init_drone(nil, Storage::Memory.new)
  end
  
  describe "A sample of 100 out of 1000 elements" do
    before do
      @population = (0...100)
      @sample = ExponentiallyDecayingSample.new('id1', 1000, 0.99)
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
      @population = (0...100)
      @sample = ExponentiallyDecayingSample.new('id1', 100, 0.99)
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
      Delorean.time_travel_to("1 hours from now") do
        @sample.update(42)
      end
      
      @sample.size.should == 100
      @sample.values.size.should == 100
    end
    
  end
  
  
  describe "A heavily-biased sample of 100 out of 1000 elements" do
    before do
      @population = (0...100)
      @sample = ExponentiallyDecayingSample.new('id1', 100, 0.01)
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
      Delorean.time_travel_to("1 hours from now") do
        @sample.update(42)
      end
      
      @sample.size.should == 100
      @sample.values.size.should == 100
    end
    
  end
  
  describe "A heavily-biased sample of 1000 out of 1000 elements" do
    before do
      @population = (0...1000)
      @sample =  ExponentiallyDecayingSample.new('id1', 1000, 0.01)
      @population.step(1){|n| @sample.update(n) }
    end
    
    it "should have 1000 elements" do
      @sample.size.should == 1000
      @sample.values.length.should == 1000
    end

    it "should only have elements from the population" do
      values = @sample.values
      @population.each do |datum|
        values.should.include?(datum)
      end
    end
    
    it "should replace an element when updating" do
      Delorean.time_travel_to("10 minutes from now") do
        @sample.update(4242)
        @sample.size.should == 1000
        @sample.values.should.include?(4242)
      end
    end
    
    it "should rescale so that newer events are higher in priority in the hash" do 
      Delorean.time_travel_to("1 hour from now") do
        @sample.update(2121)
        @sample.size.should == 1000
      end
      
      Delorean.time_travel_to("2 hours from now") do
        @sample.update(4242)
        @sample.size.should == 1000
        
        values = @sample.values
        
        values.length.should == 1000
        values.should.include?(4242)
        values.should.include?(2121)
        
        # Most recently added values in time should be at the end with the highest priority
        values[999].should == 4242
        values[998].should == 2121
      end
      
    end
  end
  
end
