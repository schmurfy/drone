# -*- encoding: utf-8 -*-
require File.expand_path('../../../lib/drone/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "drone_collectd"
  s.version     = Drone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Ammous"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{Drone Collectd Interface}
  s.description = %q{Collectd Interface for Drone}

  s.rubyforge_project = "drone_collectd"

  s.files         = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files    = Dir['specs/**/*']
  s.require_paths = ["lib"]
  
  s.add_dependency('drone',         '~> 1.0.4')
  s.add_dependency('eventmachine',  '>= 0.12.10')
  
  s.add_development_dependency("mocha")
  s.add_development_dependency("bacon")
  s.add_development_dependency("schmurfy-em-spec")
  s.add_development_dependency("delorean")
  s.add_development_dependency("simplecov")
end
