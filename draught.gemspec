# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'draught/version'

Gem::Specification.new do |spec|
  spec.name          = "draught"
  spec.version       = Draught::VERSION
  spec.authors       = ["Matt Patterson"]
  spec.email         = ["matt@reprocessed.org"]

  spec.summary       = %q{A library for creating 2D vector graphics as PDF.}
  spec.homepage      = "https://github.com/fidothe/draught"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "prawn", "~> 2.1"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'simplecov'
end
