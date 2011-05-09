# -*- encoding: utf-8 -*-
require File.expand_path('../../../lib/drone/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "drone_redis"
  s.version     = Drone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien ammous"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{Redis Storage for Drone}
  s.description = %q{-}

  s.rubyforge_project = "drone_redis"

  s.files         = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files    = Dir['specs/**/*']
  s.require_paths = ["lib"]
  
  s.add_dependency('superfeedr-em-redis')
  s.add_dependency('drone',         '~> 1.0.4')
end
