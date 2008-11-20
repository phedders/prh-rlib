require 'rubygems'
load 'prh-rlib.gemspec'

Rake::GemPackageTask.new(@spec) do |pkg|
  pkg.need_tar = true
end

task :default => "pkg/#{@spec.name}-#{@spec.version}.gem" do
  puts "generated latest version"
end
