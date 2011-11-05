require "bundler/gem_tasks"

task :default => :"test:core"

EXTENSIONS = Dir[File.expand_path('../extensions/*', __FILE__)].map{|path|  File.basename(path) }

namespace :test do
  desc "core specs"
  task :core do
    require 'bacon'
  
    Dir[File.expand_path('../specs/**/*_spec.rb', __FILE__)].each do |file|
      load(file)
    end
    
    EXTENSIONS.each do |ext|
      Rake::Task["test:#{ext}"].invoke
    end
  end



  EXTENSIONS.each do |ext|
    desc "specs for #{ext}"
    task ext do
      require 'bacon'
      Dir[File.expand_path("../extensions/#{ext}/specs/**/*_spec.rb", __FILE__)].each do |file|
        load(file)
      end
    end
  end
  
end

