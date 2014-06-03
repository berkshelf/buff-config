# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buff/config/version'

Gem::Specification.new do |spec|
  spec.name          = "buff-config"
  spec.version       = Buff::Config::VERSION
  spec.authors       = ["Jamie Winsor", "Kyle Allan"]
  spec.email         = ["jamie@vialstudios.com", "kallan@riotgames.com"]
  spec.description   = %q{A simple configuration class}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/RiotGames/buff-config"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 1.9.2"

  spec.add_dependency "varia_model", "~> 0.4"
  spec.add_dependency "buff-extensions", "~> 1.0"

  spec.add_development_dependency "buff-ruby_engine", "~> 0.1"
  spec.add_development_dependency "thor", "~> 0.18.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fuubar"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-spork"
  spec.add_development_dependency "spork"
  spec.add_development_dependency "json_spec"
end
