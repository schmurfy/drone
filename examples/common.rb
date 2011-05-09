
require 'rubygems'


def init_environment(extension = nil)
  if extension
    # use the correct Gemfile
    ENV['BUNDLE_GEMFILE'] = File.expand_path("../../extensions/#{extension}/Gemfile", __FILE__)
  end
  
  require 'bundler/setup'
  
  $LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
  
  require 'drone'
  
  if extension
    $LOAD_PATH.unshift(File.expand_path("../../extensions/#{extension}/lib", __FILE__))
    require extension
  end
  
end


