require 'bundler'

Bundler::GemHelper.install_tasks

task :spec do
  ENV['COVERAGE'] = "1"
  Dir.chdir( File.dirname(__FILE__) ) do
    Dir["specs/**/*_spec.rb"].each do |path|
      load(path)
    end
  end
end

begin
  require 'yard'
  require 'bluecloth'
  YARD::Rake::YardocTask.new(:doc)
rescue
  
end