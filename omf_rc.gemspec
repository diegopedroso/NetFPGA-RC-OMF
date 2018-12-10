# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../../omf_common/lib", __FILE__)
require "omf_rc/version"

Gem::Specification.new do |s|
  s.name        = "omf_rc"
  s.version     = OmfRc::VERSION
  s.authors     = ["NICTA"]
  s.email       = ["omf-user@lists.nicta.com.au"]
  s.homepage    = "http://omf.mytestbed.net"
  s.summary     = %q{OMF resource controller}
  s.description = %q{Resource controller of OMF, a generic framework for controlling and managing networking testbeds.}
  s.required_ruby_version = '>= 1.9.3'
  s.license = 'MIT'

  s.rubyforge_project = "omf_rc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "minitest"
  s.add_development_dependency "pry"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "mocha"
  s.add_runtime_dependency "omf_common", "= #{OmfCommon::VERSION}"
  s.add_runtime_dependency "cocaine"
  s.add_runtime_dependency "facter"
  s.add_runtime_dependency "macaddr", "= 1.7.1"
end
