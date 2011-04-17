$:.reject! { |e| e.include? 'TextMate' }

require 'rubygems'

puts "Testing with ruby #{RUBY_VERSION} and rubygems #{Gem::VERSION}"

require 'bundler/setup'

if (RUBY_VERSION >= "1.9") && ENV['COVERAGE']
  require 'simplecov'
  ROOT = File.expand_path('../../', __FILE__)
  
  puts "[[  SimpleCov enabled  ]]"
  
  SimpleCov.start do
    add_filter '/gems/'
    add_filter '/specs/'
    
    root(ROOT)
  end
end

require 'bacon'
require 'mocha'
require 'delorean'
require 'em-spec/bacon'
EM.spec_backend = EventMachine::Spec::Bacon

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

module Bacon
  module MochaRequirementsCounter
    def self.increment
      Counter[:requirements] += 1
    end
  end
  
  class Context
    include Mocha::API
    
    alias_method :it_before_mocha, :it
    
    def it(description)
      it_before_mocha(description) do
        begin
          mocha_setup
          yield
          mocha_verify(MochaRequirementsCounter)
        rescue Mocha::ExpectationError => e
          raise Error.new(:failed, "#{e.message}\n#{e.backtrace[0...10].join("\n")}")
        ensure
          mocha_teardown
        end
      end
    end
  end
end

def focus(test_label)
  Bacon.const_set(:RestrictName, %r{#{test_label}})
end

Bacon.summary_on_exit()
