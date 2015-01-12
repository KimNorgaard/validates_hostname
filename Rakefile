require 'rubygems'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'
require 'rubygems/specification'
require 'rspec/core/rake_task'
require './lib/validates_hostname/version'

GEM_NAME = "validates_hostname"
GEM_VERSION = PAK::ValidatesHostname::VERSION
 
spec = Gem::Specification.new do |s|
  s.name                      = GEM_NAME
  s.version                   = GEM_VERSION
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
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry-debugger'
end

desc 'Test the validates_as_hostname gem/plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true 
end

desc 'Default: run specs.'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
end

desc 'Generate documentation for plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidatesHostname'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM_NAME}-#{GEM_VERSION}}
end

desc "Create a gemspec file"
task :make_spec do
  File.open("#{GEM_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
 
