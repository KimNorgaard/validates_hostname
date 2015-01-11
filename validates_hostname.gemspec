# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "validates_hostname/version"

Gem::Specification.new do |s|
  s.name                      = 'validates_hostname'
  s.version                   = PAK::ValidatesHostname::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Kim Nørgaard"]
  s.description               = 'Extension to ActiveRecord::Base for validating hostnames'
  s.summary                   = 'Checks for valid hostnames'
  s.email                     = 'jasen@jasen.dk'
  s.extra_rdoc_files          = ["README.rdoc", "CHANGELOG.rdoc", "MIT-LICENSE"]
  s.files                     = ["validates_hostname.gemspec", "MIT-LICENSE", "CHANGELOG.rdoc", "README.rdoc", "Rakefile", "lib/validates_hostname", "lib/validates_hostname/version.rb", "lib/validates_hostname.rb"]
  s.homepage                  = %q{https://github.com/KimNorgaard/validates_hostname}
  s.licenses                  = 'MIT'
  s.require_paths             = ["lib"]

  s.add_runtime_dependency 'activerecord', '>= 3.0'
  s.add_runtime_dependency 'activesupport', '>= 3.0'

  s.add_development_dependency 'rails'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3-ruby'
end
