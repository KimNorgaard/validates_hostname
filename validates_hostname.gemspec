# frozen_string_literal: true

# stub: validates_hostname 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = 'validates_hostname'
  s.version = '2.0.0'
  s.required_ruby_version = '>= 3.0.0'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.require_paths = ['lib']
  s.authors = ['Kim Nøgaard']
  s.date = '2025-09-21'
  s.description = 'Extension to ActiveModel for validating hostnames'
  s.email = 'jasen@jasen.dk'
  s.extra_rdoc_files = ['README.md', 'CHANGELOG.md', 'LICENSE']
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.homepage = 'https://github.com/KimNorgaard/validates_hostname'
  s.licenses = ['MIT']
  s.summary = 'Checks for valid hostnames'

  s.specification_version = 4 if s.respond_to? :specification_version

  if s.respond_to? :add_runtime_dependency
    s.add_runtime_dependency('activemodel', [' >= 6.0', '< 8'])
    s.add_runtime_dependency('activesupport', [' >= 6.0', '< 8'])
    s.add_development_dependency('rspec', ['~> 3.13'])
    s.add_development_dependency('rspec-collection_matchers', ['~> 1.2'])
    s.add_development_dependency('rubocop', ['~> 1.80'])
    s.add_development_dependency('guard', ['~> 2.19'])
    s.add_development_dependency('guard-rspec', ['~> 4.7'])
  else
    s.add_dependency('activemodel', ['>= 6.0', '< 8'])
    s.add_dependency('activesupport', ['>= 6.0', '< 8'])
    s.add_dependency('rspec', ['~> 3.13'])
    s.add_dependency('rspec-collection_matchers', ['~> 1.2'])
    s.add_dependency('rubocop', ['~> 1.80'])
    s.add_dependency('guard', ['~> 2.19'])
    s.add_dependency('guard-rspec', ['~> 4.7'])
  end
end
