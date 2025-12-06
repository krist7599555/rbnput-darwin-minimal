require_relative "lib/rbnput/version"

Gem::Specification.new do |spec|
  spec.name          = "rbnput-darwin-minimal"
  spec.version       = Rbnput::VERSION
  spec.authors       = ["Krist Ponpairin"]
  spec.email         = ["krist7599555@gmail.com"]

  spec.summary       = "Minimal Ruby keyboard listener for macOS using FFI"
  spec.description   = "Lightweight Ruby library for low-level keyboard monitoring on macOS, implemented through FFI bindings to Darwin system libraries."

  # 🏡 Project Links
  spec.homepage      = "https://github.com/krist7599555/rbnput-darwin-minimal"
  spec.metadata = {
    "homepage_uri"      => "https://github.com/krist7599555/rbnput-darwin-minimal",
    "source_code_uri"   => "https://github.com/krist7599555/rbnput-darwin-minimal",
    "bug_tracker_uri"   => "https://github.com/krist7599555/rbnput-darwin-minimal/issues",
    "documentation_uri" => "https://github.com/krist7599555/rbnput-darwin-minimal",
    "changelog_uri"     => "https://github.com/krist7599555/rbnput-darwin-minimal/releases"
  }

  # 📦 Files
  spec.files         = Dir["lib/**/*.rb"] + ["README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  # 💎 Dependencies
  spec.add_dependency "ffi", "~> 1.15"

  # Ruby version
  spec.required_ruby_version = ">= 3.0"

   spec.extra_rdoc_files = ['README.md']
end