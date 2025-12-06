require_relative 'lib/rbnput/version'

Gem::Specification.new do |spec|
  spec.name          = "rbnput-darwin-minimal"
  spec.version       = Rbnput::VERSION
  spec.authors       = ["Krist Ponpairin"]
  spec.email         = ["krist7599555@gmail.com"]
  spec.summary       = "Ruby Input library (rbnput)"
  spec.description   = "A Ruby library for keyboard monitoring in mac"
  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
  spec.add_dependency "ffi", "~> 1.15"
end
