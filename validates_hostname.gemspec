# -*- encoding: utf-8 -*-
# stub: validates_hostname 1.0.10 ruby lib

Gem::Specification.new do |s|
  s.name = "validates_hostname".freeze
  s.version = "1.0.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kim N\u00F8rgaard".freeze]
  s.date = "2020-02-18"
  s.description = "Extension to ActiveRecord::Base for validating hostnames".freeze
  s.email = "jasen@jasen.dk".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze, "CHANGELOG.rdoc".freeze, "MIT-LICENSE".freeze]
  s.files = ["CHANGELOG.rdoc".freeze, "MIT-LICENSE".freeze, "README.rdoc".freeze, "Rakefile".freeze, "lib/validates_hostname".freeze, "lib/validates_hostname.rb".freeze, "lib/validates_hostname/version.rb".freeze, "validates_hostname.gemspec".freeze]
  s.homepage = "https://github.com/KimNorgaard/validates_hostname".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Checks for valid hostnames".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 3.0"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec-collection_matchers>.freeze, [">= 0"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 3.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-collection_matchers>.freeze, [">= 0"])
  end
end
