require File.expand_path('../../common', __FILE__)

require 'drone/utils/ewma'

describe 'EWMA' do
  
  describe 'A 1min EWMA with a value of 3' do
    before do
      @ewma = EWMA.one_minute_ewma
      @ewma.update(3)
      @ewma.tick()
    end
    
    
    def mark_minutes(minutes)
      1.upto( (minutes*60.0) / 5 ) do
        @ewma.tick()
      end
    end
    
    should "have a rate of 0.6 events/sec after the first tick" do
      @ewma.rate.should.be.close(0.6, 0.000001)
    end
    
    {
      1   => 0.22072766,
      2   => 0.08120117,
      3   => 0.02987224,
      4   => 0.01098938,
      5   => 0.00404277,
      6   => 0.00148725,
      7   => 0.00054713,
      8   => 0.00020128,
      9   => 0.00007405,
      10  => 0.00002724,
      11  => 0.00001002,
      12  => 0.00000369,
      13  => 0.00000136,
      14  => 0.00000050,
      15  => 0.00000018
      
    }.each do |minutes, expected|
      should "have a rate of #{expected} events/sec after #{minutes} minute(s)" do
        mark_minutes(minutes)
        @ewma.rate.should.be.close(expected, 0.00000001)
      end
    end
    
  end
  
  
  
  describe 'A 5min EWMA with a value of 3' do
    before do
      @ewma = EWMA.five_minutes_ewma
      @ewma.update(3)
      @ewma.tick()
    end
    
    should "have a rate of 0.6 events/sec after the first tick" do
      @ewma.rate.should.be.close(0.6, 0.000001)
    end
    
    def mark_minutes(minutes)
      1.upto( (minutes*60.0) / 5 ) do
        @ewma.tick()
      end
    end
    
    {
      1  => 0.49123845,
      2  => 0.40219203,
      3  => 0.32928698,
      4  => 0.26959738,
      5  => 0.22072766,
      6  => 0.18071653,
      7  => 0.14795818,
      8  => 0.12113791,
      9  => 0.09917933,
      10 => 0.08120117,
      11 => 0.06648190,
      12 => 0.05443077,
      13 => 0.04456415,
      14 => 0.03648604,
      15 => 0.02987224
    }.each do |minutes, expected|
      should "have a rate of #{expected} events/sec after #{minutes} minute(s)" do
        mark_minutes(minutes)
        @ewma.rate.should.be.close(expected, 0.00000001)
      end
    end
    
  end
  
  
  describe 'A 15min EWMA with a value of 3' do
    before do
      @ewma = EWMA.fifteen_minutes_ewma
      @ewma.update(3)
      @ewma.tick()
    end
    
    should "have a rate of 0.6 events/sec after the first tick" do
      @ewma.rate.should.be.close(0.6, 0.000001)
    end
    
    def mark_minutes(minutes)
      1.upto( (minutes*60.0) / 5 ) do
        @ewma.tick()
      end
    end
    
    {
      1   => 0.56130419,
      2   => 0.52510399,
      3   => 0.49123845,
      4   => 0.45955700,
      5   => 0.42991879,
      6   => 0.40219203,
      7   => 0.37625345,
      8   => 0.35198773,
      9   => 0.32928698,
      10  => 0.30805027,
      11  => 0.28818318,
      12  => 0.26959738,
      13  => 0.25221023,
      14  => 0.23594443,
      15  => 0.22072766
    }.each do |minutes, expected|
      should "have a rate of #{expected} events/sec after #{minutes} minute(s)" do
        mark_minutes(minutes)
        @ewma.rate.should.be.close(expected, 0.00000001)
      end
    end
    
  end
  
end
