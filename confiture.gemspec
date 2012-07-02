# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "confiture/version"

Gem::Specification.new do |s|
  s.name        = "confiture"
  s.version     = Confiture::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Peter Schröder']
  s.email       = ['phoetmail@googlemail.com']
  s.homepage    = 'http://github.com/phoet/confiture'
  s.summary     = s.description = 'Confiture helps with configuring your gem.'

  s.rubyforge_project = "confiture"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rake',  '~> 0.9.2')
  s.add_development_dependency('rspec', '~> 2.7')
  s.add_development_dependency('pry',   '~> 0.9.9')
end
