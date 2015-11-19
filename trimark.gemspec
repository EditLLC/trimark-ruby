# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trimark/version'

Gem::Specification.new do |spec|
  spec.name          = "trimark"
  spec.version       = Trimark::VERSION
  spec.authors       = ["Tyler Whitsett"]
  spec.email         = ["whitsett.tyler@gmail.com"]

  spec.summary       = %q{A Ruby wrapper for the TriMark JSON API}
  spec.description   = %q{Eventually}
  spec.homepage      = "https://github.com/EditLLC/trimark-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9.5"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'virtus'
  spec.add_runtime_dependency 'addressable'


end
