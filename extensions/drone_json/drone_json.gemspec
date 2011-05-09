# -*- encoding: utf-8 -*-
require File.expand_path('../../../lib/drone/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "drone_json"
  s.version     = Drone::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Julien Ammous"]
  s.email       = []
  s.homepage    = ""
  s.summary     = %q{Drone Interface}
  s.description = %q{JSON Interface for Drone}

  s.rubyforge_project = "drone_json"

  s.files         = Dir['LICENSE', 'README.md', 'lib/**/*']
  s.test_files    = Dir['specs/**/*']
  s.require_paths = ["lib"]
  
  s.add_dependency('drone',         '~> 1.0.4')
  s.add_dependency('thin')
  
  if RUBY_VERSION < "1.9.1"
    s.add_dependency('json')
  end
  
  s.add_development_dependency("mocha")
  s.add_development_dependency("bacon")
  s.add_development_dependency("schmurfy-em-spec")
  s.add_development_dependency("delorean")
  s.add_development_dependency("simplecov")
end
