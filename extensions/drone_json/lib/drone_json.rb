require 'drone'

module DroneJson
  def self.require_lib(path)
    require File.expand_path("../#{path}", __FILE__)
  end
  
  require_lib('drone_json/json')
end
