# This file is a shortcut to run all tests in textmate

ENV['COVERAGE'] = "1"
require File.expand_path('../common', __FILE__)


Dir.chdir( File.dirname(__FILE__) ) do
  Dir["**/*_spec.rb"].each do |path|
    load(path)
  end
end
