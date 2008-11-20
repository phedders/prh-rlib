require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "prh-rlib"
  s.version   =   "0.1"
  s.author    =   "Paul Hedderly"
  s.email     =   "paul+ruby @nospam@ mjr.org"
  s.summary   =   "A bunch of other stuffs."
  s.files     =   FileList['lib/*.rb', 'test/*'].to_a
  s.require_path  =   "lib"
  s.autorequire   =   "prh-ruby"
  s.test_files = Dir.glob('tests/*.rb')
  s.has_rdoc  =   true
  s.extra_rdoc_files  =   ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
  puts "generated latest version"
end
