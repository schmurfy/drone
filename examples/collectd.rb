require File.expand_path('../common', __FILE__)
init_environment('drone_collectd')

Drone::init_drone()
Drone::register_gauge("cpu:user/gauge"){ rand(200) }

class User
  include Drone::Monitoring
  
  def initialize(name)
    @name = name
  end
  
  monitor_rate("apps:app1/meter")
  def rename(new_name)
    @name = new_name
  end
  
  monitor_time("apps:app1/timer")
  def do_something
    # just eat some cpu
    0.upto(rand(2000)) do |n|
      str = "a"
      200.times{ str << "b" }
    end
  end
end

EM::run do
  Drone::add_output(:collectd, 2,
      :hostname => 'my_app',
      :address => '127.0.0.1',
      :port => 25826,
      :percentiles => [0.5, 0.75, 0.95]
    )
  Drone::start_monitoring()
  
  counter1 = Drone::register_counter("apps:app1/counter")
  counter1.increment()
  
  a = User.new("bob")
  
  EM::add_periodic_timer(2) do
    rand(100).times{|n| a.rename("user#{n}") }
    counter1.increment()
  end
  
  EM::add_periodic_timer(1) do
    a.do_something()
  end
end
