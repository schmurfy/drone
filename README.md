
# What is this ?

Drone is a monitoring library designed to collect data from your application and export them
to virtually any monitoring tool.
Its core is heavily based on the impressive works of Coda Hale on the metrics java library.


# How is it done

The library is split in different parts

- the core
  it contains all the API used to declare which data to collect and how as well as the storage for them

- the metrics
  that is all the metrics type the library know.

- the interfaces
  those are the parts which will decides how the stored data are made available.

- the schedulers
  this is where the timers are scheduled, currently there is only one scheduler: eventmachine

# Supported Runtimes

- MRI 1.8.7+
- Rubinius 1.2.2+

# Usage
  
  I try to keep things as simple as possible, there is currently two ways to use
  this library:
  
  - the first one is to just instantiate metrics by hand and use them directly
    
        require 'drone'
        Drone::init_drone()
        @counter = Drone::Metris::Counter.new('my_counter')
        
        def some_method
          @counter.inc()
        end
  
  - the other way is to instrument a class:
  
        require 'drone'
        Drone::init_drone()
        
        class User
          include Drone::Monitoring
          
          monitor_rate("users/new")
          def initialize(login, pass); end
          
          monitor_time("users/rename")
          def rename(new_login); end
          
        end
      
      This code will create three metrics:
      - "users/new"       : how many users are created each second
      - "users/rename"    : how much time renaming a user takes and how many users are renamed
                            each second
      
  
Once you have your data you need to add a way to serve them, each lives in a separate
gem to limit the core's dependencies so the only one in core is:
  
  - console output (puts), mainly for debug:
      
        require 'drone'
        Drone::init_drone()
        Drone::add_output(:console, 1)
      
      The values will be printed on the console at the inter
  
# Goals

  My goal is to be able to serve stats efficiently from any ruby 1.9 application built
  on top of eventmachine and fibers but I built the library to allow non eventmachine uses too, for
  now the only part where eventmachine is required is the scheduler.
  
  Implementing a scheduler based on a background Thread is possible but before that work
  needs to be done to ensure thread safety, Actually the library is not thread safe.
  
  if someone wants to implements it I am not against it but I prefer it to be added as an
  optional part instead of in the core. There should not be any problem to implements it
  in an includable module not included as default (it may requires some modifications in the core):
  
    require 'drone'
    require 'drone/threadsafe'
    
    [...]
  
  
# Development

  Installing the development environment is pretty simple thanks to bundler:
    
    gem install bundler
    bundle
  
## Running specs
  
  The specs are written with bacon, mocha and em-spec, they can be ran with:
    
    rake spec
  
## Build the doc
  You will need the gems: yard and bluecloth and then run:
  
    rake doc
