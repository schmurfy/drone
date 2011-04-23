module Drone
  class Metric
    ##
    # Every metric must have a name to be referenced by
    # 
    # @attr_reader [String] name The metric's name
    #   (which is also its id)
    # 
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
    
  end
end
