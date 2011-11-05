# A sample Guardfile
# More info at https://github.com/guard/guard#readme


# parameters:
#  output     => the formatted to use
#  backtrace  => number of lines, nil =  everything
guard 'bacon', :output => "BetterOutput", :backtrace => 4 do
  watch(%r{^lib/drone/(.+)\.rb$})     { |m| "specs/#{m[1]}_spec.rb" }
  watch(%r{specs/.+\.rb$})
end

