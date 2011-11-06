
module Drone
  def self.require_lib(path)
    require File.expand_path("../#{path}", __FILE__)
  end
  
  require_lib("drone/version")
  
  require_lib("drone/errors")
  require_lib("drone/monitoring")
  
  # Schedulers
  require_lib("drone/schedulers/eventmachine")
  
  # Metrics
  require_lib("drone/metrics/counter")
  require_lib("drone/metrics/gauge")
  require_lib("drone/metrics/histogram")
  require_lib("drone/metrics/meter")
  require_lib("drone/metrics/timer")
  
  # Output
  require_lib("drone/interfaces/console")
end
