# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "quandl/babelfish/version"

Gem::Specification.new do |s|
  s.name        = "quandl_babelfish"
  s.version     = Quandl::Babelfish::VERSION
  s.authors     = ["Sergei Ryshkevich"]
  s.email       = ["sergei@quandl.com"]
  s.homepage    = "http://quandl.com/"
  s.license     = "MIT"
  s.summary     = "Quandl Data Cleaner"
  s.description = "Quandl Data Cleaner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec", "~> 2.13"
  s.add_development_dependency "pry"
end
