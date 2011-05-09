require File.expand_path('../common', __FILE__)
init_environment('drone_json')

Drone::init_drone()
Drone::register_gauge("cpu:0/user"){ rand(200) }

class User
  include Drone::Monitoring
  
  def initialize(name)
    @name = name
  end
  
  monitor_rate("users:rename")
  def rename(new_name)
    @name = new_name
  end
  
  monitor_time("users:do_something")
  def do_something
    # just eat some cpu
    0.upto(rand(2000)) do |n|
      str = "a"
      200.times{ str << "b" }
    end
  end
end

EM::run do
  Drone::add_output(:json, '127.0.0.1', 3001)
  Drone::start_monitoring()
  
  counter1 = Drone::register_counter("something_counted")
  counter1.increment()
  
  a = User.new("bob")
  
  EM::add_periodic_timer(2) do
    rand(100).times do |n|
      ret = a.rename("user#{n}")
    end
    
    counter1.increment()
  end
  
  EM::add_periodic_timer(1) do
    a.do_something()
  end
end
