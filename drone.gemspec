# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "drone/version"

Gem::Specification.new do |s|
  s.name        = "drone"
  s.version     = Drone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Ammous"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{Drone is a monitoring library}
  s.description = %q{Drone is a monitoring library based on the metrics java library}

  s.rubyforge_project = "drone"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("eventmachine",  ">= 0.12.10")
  s.add_dependency("flt",           "~> 1.3.0")
  
end
