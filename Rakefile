require 'bundler'

# Bundler::GemHelper.install_tasks

GEM_FOLDER = File.expand_path('../pkg', __FILE__)


def build_gem(path)
  dir = File.dirname(path)
  f = File.basename(path)
  
  sh "cd #{dir} && gem build #{f} && mv *.gem #{GEM_FOLDER}/"
end

task :build do
  # drone
  build_gem(File.expand_path('../drone.gemspec', __FILE__))
  
  # extensions
  Dir["extensions/**/*.gemspec"].each do |path|
    build_gem(path)
  end

end


# task :release do
#   Dir.chdir(File.expand_path('../pkg', __FILE__)) do
#     %()
#     
#   end
# end

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
rescue LoadError
  
end