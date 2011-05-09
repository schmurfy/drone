require File.expand_path('../common', __FILE__)
init_environment('drone_redis')

Drone::init_drone(
    Drone::Schedulers::EMScheduler,
    Drone::Storage::Redis.new('127.0.0.1', 1)
  )

Drone::register_gauge("cpu:0/user"){ rand(200) }

class User
  include Drone::Monitoring
  
  def initialize(name)
    @name = name
  end
  
  monitor_rate("users:rename:rate")
  def rename(new_name)
    @name = new_name
  end
  
  monitor_time("users:do_something:time")
  monitor_rate("users:do_something:rate")
  def do_something
    # just eat some cpu
    0.upto(rand(2000)) do |n|
      str = "a"
      200.times{ str << "b" }
    end
  end
end

EM::run do
  # Drone::add_output(:json, '127.0.0.1', 3001)
  
  Fiber.new do
    Drone::start_monitoring()
  end.resume
  
  counter1 = Drone::register_counter("something_counted")
  a = nil
  Fiber.new do
    counter1.increment()
    a = User.new("bob")
  end.resume
  
  EM::add_periodic_timer(2) do
    Fiber.new do
      rand(100).times{|n| a.rename("user#{n}") }
      counter1.increment()
    end.resume
  end
  
  EM::add_periodic_timer(1) do
    Fiber.new do
      a.do_something()
    end.resume
  end
end
