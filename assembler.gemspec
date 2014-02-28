# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assembler/version'

Gem::Specification.new do |spec|
  spec.name          = "assembler"
  spec.version       = Assembler::VERSION
  spec.authors       = ["Ben Hamill"]
  spec.email         = ["git-commits@benhamill.com"]
  spec.summary       = %q{Block-based initializers for your objects.}
  spec.description   = %q{Provides a DSL for describing required and optional (with defaults) parameters for object initialization. The initializer accepts an options hash and/or yields a builder object to a block.}
  spec.homepage      = "https://github.com/benhamill/assembler#readme"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
