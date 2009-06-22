Gem::Specification.new do |s|
  s.name    = 'validates_as_hostname'
  s.version = '1.0.0'
  s.date    = '2009-06-17'
  
  s.summary     = 'Checks for valid hostnames'
  s.description = 'Extension to ActiveRecord::Base for validating hostnames'
  
  s.author   = 'Kim Nørgaard'
  s.email    = 'jasen@jasen.dk'
  s.homepage = 'http://jasen.dk'
  
  s.has_rdoc = false
  
  s.files = %w(
    CHANGELOG
    init.rb
    lib/validates_as_hostname.rb
    MIT-LICENSE
    Rakefile
    README
  )
  
  s.test_files = %w(
    test/validates_as_hostname_test.rb
  )
end
