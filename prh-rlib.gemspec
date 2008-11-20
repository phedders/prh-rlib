require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

@spec = Gem::Specification.new do |s|
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "prh-rlib"
  s.version   =   "0.1"
  s.author    =   "Paul Hedderly"
  s.email     =   "paul+ruby @nospam@ mjr.org"
  s.summary   =   "A bunch of other stuffs."
  s.files     =   FileList['lib/*.rb', 'test/*'].to_a
  s.require_path  =   "lib"
  s.test_files = Dir.glob('tests/*.rb')
  s.has_rdoc  =   true
  s.extra_rdoc_files  =   ["README"]
  s.homepage  =   "http://github.com/phedders/prh-rlib"
  s.add_dependency("net-ssh", ["> 0.0.0"])
  s.add_dependency("schacon-git", ["> 0.0.0"])
  s.add_dependency("mhash", ["> 0.0.0"])
end

