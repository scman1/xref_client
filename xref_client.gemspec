require_relative "lib/xref_client/version"

Gem::Specification.new do |spec|
  spec.name        = "xref_client"
  spec.version     = XrefClient::VERSION
  spec.authors     = ["Abraham Nieva"]
  spec.email       = ["a_nieva@hotmail.com"]
  spec.homepage    = "https://github.com/scman1/xref_client.git"
  spec.summary     = "Summary of XrefClient."
  spec.description = "Description of XrefClient."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/scman1/xref_client/"
  spec.metadata["changelog_uri"] = "https://github.com/scman1/xref_client/"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3.2"
  spec.add_dependency "serrano"
end
