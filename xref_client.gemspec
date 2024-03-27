$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "xref_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "xref_client"
  spec.version     = XrefClient::VERSION
  spec.authors     = ["Abraham Nieva"]
  spec.email       = ["a_nieva@hotmail.com"]
  spec.homepage    = ""
  spec.summary     = "Summary of XrefClient."
  spec.description = "Description of XrefClient."
  spec.license     = ""

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 7.1.3", ">= 7.1.3.2"

  spec.add_development_dependency 'serrano', '~> 1.4'

  spec.add_development_dependency "sqlite3"
end
