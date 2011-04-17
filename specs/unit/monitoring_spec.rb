require File.expand_path('../../common', __FILE__)

require 'drone'
require 'drone/monitoring'

EM.describe 'Monitoring' do
  describe 'rate monitor' do
    before do
      
      Drone::init_drone()
      
      @klass = Class.new() do
        include Drone::Monitoring
        
        monitor_rate("users/no_args")
        def a_method_without_args; 42; end
        
        monitor_rate("users/with_args")
        def method_with_args(a, b); a + b; end
        
        monitor_rate("users/with_block")
        def method_with_block(&block); block.call; end
        
      end
      @obj = @klass.new
      
    end
    
    should 'reuse same meter for every instances of this class' do
      meter = Drone::find_metric("users/no_args")
      meter.count.should == 0
      
      obj1 = @klass.new
      obj2 = @klass.new
      
      obj1.a_method_without_args()
      meter.count.should == 1
      
      obj2.a_method_without_args()
      meter.count.should == 2
      
      done
    end
    
    should 'increment counter on call' do
      Drone::Metrics::Meter.any_instance.expects(:mark)
      
      ret = @obj.a_method_without_args()
      ret.should == 42
      done
    end
    
    should 'be transparent for method with arguments' do
      Drone::Metrics::Meter.any_instance.expects(:mark)
      
      ret = @obj.method_with_args(4, 5)
      ret.should == 9
      done
    end
    
    should 'be transparent for method with block argument' do
      Drone::Metrics::Meter.any_instance.expects(:mark)
      
      ret = @obj.method_with_block(){ 32 }
      ret.should == 32
      done
    end
    
  end
  
  
  describe 'timing monitor' do
    before do
      
      Drone::init_drone()
      
      klass = Class.new() do
        include Drone::Monitoring
        
        monitor_time("users/no_args")
        def a_method_without_args; 42; end
        
        monitor_time("users/with_args")
        def method_with_args(a, b); a + b; end
        
        monitor_time("users/with_block")
        def method_with_block(&block); block.call; end
        
      end
      @obj = klass.new
      
    end
    
    should 'time call with no args' do
      Drone::Metrics::Timer.any_instance.expects(:update).with{|delay|
          delay.should.be.close?(0, 0.001)
          true
        }
      
      ret = @obj.a_method_without_args()
      ret.should == 42
      done
    end
    
    should 'time call with args' do
      Drone::Metrics::Timer.any_instance.expects(:update).with{|delay|
          delay.should.be.close?(0, 0.001)
          true
        }
      
      ret = @obj.method_with_args(2, 4)
      ret.should == 6
      done
    end
    
    should 'time call with a block' do
      Drone::Metrics::Timer.any_instance.expects(:update).with{|delay|
          delay.should.be.close?(0, 0.001)
          true
        }
      
      ret = @obj.method_with_block(){ 42 }
      ret.should == 42
      done
    end
    
  end
  
end
