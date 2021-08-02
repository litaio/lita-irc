# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "lita-irc"
  spec.version       = "2.2.0"
  spec.authors       = ["Jimmy Cuadra"]
  spec.email         = ["jimmy@jimmycuadra.com"]
  spec.description   = "An IRC adapter for Lita."
  spec.summary       = "An IRC adapter for the Lita chat robot."
  spec.homepage      = "https://github.com/jimmycuadra/lita-irc"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "adapter" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_runtime_dependency "cinch", ">= 2.0"
  spec.add_runtime_dependency "lita", ">= 4.0"

  spec.add_development_dependency "pry-byebug", "~> 3.9.0"
  spec.add_development_dependency "rake", "~> 13.0.3"
  spec.add_development_dependency "rspec", "~> 3.10.0"
  spec.add_development_dependency "rubocop", "~> 1.17.0"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
end
