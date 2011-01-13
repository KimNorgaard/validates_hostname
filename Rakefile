<<<<<<< HEAD
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.


require File.expand_path('../config/application', __FILE__)
Pak::Application.load_tasks
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
 
desc 'Default: run tests'
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
end
 
desc 'Generate documentation for PAK.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PAK'
=======
require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'rspec/core/rake_task'
require './lib/validates_hostname/version'

GEM_NAME = "validates_hostname"
GEM_VERSION = PAK::ValidatesHostname::VERSION
 
spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "validates_hostname"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc", "MIT-LICENSE"]
  s.summary = %q{Checks for valid hostnames}
  s.description = %q{Extension to ActiveRecord::Base for validating hostnames}
  s.author = "Kim Norgaard"
  s.email = "jasen@jasen.dk"
  s.homepage = "https://github.com/KimNorgaard/validates_hostname"
  s.require_path = 'lib'
  s.files = %w(validates_hostname.gemspec MIT-LICENSE CHANGELOG.rdoc README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
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
>>>>>>> 8b57c90ef9138acf3500c3a0102161335ff0d878
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::GemPackageTask.new(spec) do |pkg|
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
 
