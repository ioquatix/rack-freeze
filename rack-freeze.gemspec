# coding: utf-8
require_relative 'lib/rack/freeze/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-freeze"
  spec.version       = Rack::Freeze::VERSION
  spec.authors       = ["Samuel Williams"]
  spec.email         = ["samuel.williams@oriontransfer.co.nz"]

  spec.summary       = "Provides a policy for frozen rack middleware."
  spec.homepage      = "https://github.com/ioquatix/rack-freeze"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
