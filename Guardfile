guard :rspec, cmd: "rbenv exec bundle exec rspec" do
  # Watch spec files
  watch(%r{^spec/.+_spec\.rb$})

  # Watch lib files and run the corresponding spec
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }

  # Watch the spec_helper and run all specs
  watch('spec/spec_helper.rb') { "spec" }
end
