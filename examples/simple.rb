require 'rubygems'
require 'bundler/setup'

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'drone'

Drone::init_drone()
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

Drone::add_output(:console, 1)

EM::run do
  Drone::start_monitoring()
  
  counter1 = Drone::register_counter("something_counted")
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
