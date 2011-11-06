module Drone
  ##
  # Generic base class for all the errors drone can raises
  class DroneError < RuntimeError; end
  
  ##
  # Raised when trying to reuse a meter name with a different
  # type.
  class AlreadyDefined < DroneError; end
  
end
