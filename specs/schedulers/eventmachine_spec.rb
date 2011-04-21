require File.expand_path('../../common', __FILE__)

require 'drone/schedulers/eventmachine'

describe 'Eventmachine Scheduler' do
  
  describe 'in waiting state' do
    before do
      @scheduler = Drone::Schedulers::EMScheduler
      class << @scheduler
        def timers_periodic;  @timers_periodic; end
        def timers_once;      @timers_once; end
      end
      
      EM::reactor_running?.should == false
      
      @scheduler.reset()
    end
    
    should "enqueue timers" do
      n = 0
      @scheduler.schedule_once(1){ n = 10 }
      n.should == 0
      @scheduler.timers_once.size.should == 1
    end
    
    should "enqueue periodic timers" do
      n = 0
      @scheduler.schedule_periodic(1){ n = 10 }
      n.should == 0
      @scheduler.timers_periodic.size.should == 1
    end
    
    should "start timers when started" do
      EM::expects(:add_periodic_timer).once.with(12)
      @scheduler.schedule_periodic(12){ }
      
      EM.expects(:add_timer).once.with(1)
      @scheduler.schedule_once(1){ }
      
      @scheduler.timers_periodic.size.should == 1
      @scheduler.timers_once.size.should == 1
      
      @scheduler.start
    end
    
  end
  
  
  EM.describe 'in started state' do
    before do
      @scheduler = Drone::Schedulers::EMScheduler
      @scheduler.reset()
      EM::reactor_running?.should == true
      @scheduler.start()
    end
    
    should 'start a timer when a job is scheduled' do
      EM::expects(:add_timer).with(23)
      @scheduler.schedule_once(23){}
      done
    end
    
    should 'start run the job and start a periodic timer when a periodic job is scheduled' do
      n = 0
      proc = lambda do
        n+= 1
        done if n == 2
      end
      
      @scheduler.schedule_periodic(0.001, &proc)
    end
    
  end
  
end
