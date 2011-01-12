# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_hostname}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kim Norgaard"]
  s.date = %q{2011-01-12}
  s.description = %q{Extension to ActiveRecord::Base for validating hostnames}
  s.email = %q{jasen@jasen.dk}
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc", "MIT-LICENSE"]
  s.files = ["validates_hostname.gemspec", "MIT-LICENSE", "CHANGELOG.rdoc", "README.rdoc", "Rakefile", "lib/validates_hostname", "lib/validates_hostname/version.rb", "lib/validates_hostname.rb"]
  s.homepage = %q{https://github.com/KimNorgaard/validates_hostname}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{validates_hostname}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Checks for valid hostnames}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
