require 'spec_helper'

describe Record do
  it "should be valid with valid hostnames" do
    record = Record.new :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test.org',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should be valid with hostnames with hyphens" do
    record = Record.new :name                       => 't-est',
                        :name_with_underscores      => 't-est',
                        :name_with_wildcard         => 't-est.org',
                        :name_with_valid_tld        => 't-est.org',
                        :name_with_test_tld         => 't-test.test',
                        :name_with_numeric_hostname => 't-est',
                        :name_with_blank            => 't-est',
                        :name_with_nil              => 't-est'
    record.valid?.should be_truthy
  end

  it "should be valid with hostnames with underscores if option is true" do
    record = Record.new :name_with_underscores      => '_test',
                        :name_with_wildcard         => 'test.org',
                        :name                       => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid with hostnames with underscores if option is false" do
    record = Record.new :name_with_underscores      => '_test',
                        :name_with_wildcard         => '_test.org',
                        :name                       => '_test',
                        :name_with_valid_tld        => '_test.org',
                        :name_with_test_tld         => '_test.test',
                        :name_with_numeric_hostname => '_test',
                        :name_with_blank            => '_test',
                        :name_with_nil              => '_test'
    record.valid?.should_not be_truthy

    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should be valid with hostnames with wildcard if option is true" do
    record = Record.new :name                       => 'test',
                        :name_with_wildcard         => '*.test.org',
                        :name_with_underscores      => 'test.org',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid with hostnames with wildcard if option is false" do
    record = Record.new :name                       => '*.test',
                        :name_with_wildcard         => '*.test.org',
                        :name_with_underscores      => '*.test',
                        :name_with_valid_tld        => '*.test.org',
                        :name_with_test_tld         => '*.test.test',
                        :name_with_numeric_hostname => '*.test',
                        :name_with_blank            => '*.test',
                        :name_with_nil              => '*.test'
    record.valid?.should_not be_truthy

    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should be valid with blank hostname" do
    record = Record.new :name_with_blank            => '',
                        :name                       => 'test',
                        :name_with_wildcard         => 'test.org',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid with blank hostname" do
    record = Record.new :name                       => '',
                        :name_with_underscores      => '',
                        :name_with_wildcard         => '',
                        :name_with_valid_tld        => '',
                        :name_with_test_tld         => '',
                        :name_with_numeric_hostname => '',
                        :name_with_nil              => '',
                        :name_with_blank            => ''
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should be valid with nil hostname" do
    record = Record.new :name_with_nil              => nil,
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test.org',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test'
    record.valid?.should be_truthy
  end

  it "should be valid when domain name length between 64 and 255" do
    long_labels = (('t' * 60) + '.' + ('t' * 60))
    record = Record.new :name                       => long_labels,
                        :name_with_underscores      => long_labels,
                        :name_with_wildcard         => long_labels,
                        :name_with_valid_tld        => long_labels + ".org",
                        :name_with_test_tld         => long_labels + ".test",
                        :name_with_numeric_hostname => long_labels,
                        :name_with_blank            => long_labels,
                        :name_with_nil              => long_labels
    record.valid?.should be_truthy
  end

  it "should not be valid with too long hostname" do
    longname=('t' * 256)
    record = Record.new :name                       => longname,
                        :name_with_underscores      => longname,
                        :name_with_wildcard         => longname,
                        :name_with_valid_tld        => longname + ".org",
                        :name_with_test_tld         => longname + ".test",
                        :name_with_numeric_hostname => longname,
                        :name_with_blank            => longname,
                        :name_with_nil              => longname
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should not be valid with too long hostname label" do
    long_labels = (('t' * 64) + '.' + ('t' * 64))
    record = Record.new :name                       => long_labels,
                        :name_with_underscores      => long_labels,
                        :name_with_wildcard         => long_labels,
                        :name_with_valid_tld        => long_labels + ".org",
                        :name_with_test_tld         => long_labels + ".test",
                        :name_with_numeric_hostname => long_labels,
                        :name_with_blank            => long_labels,
                        :name_with_nil              => long_labels
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
  end

  it "shold not save with invalid characters" do
    record = Record.new
    %w( ; : * ^ ~ + ' ! # " % & / ( ) = ? $ \\ ).each do |char|
      testname="#{char}test"
      record.name                       = testname
      record.name_with_underscores      = testname
      record.name_with_wildcard         = testname
      record.name_with_valid_tld        = testname + ".org"
      record.name_with_test_tld         = testname + '.test'
      record.name_with_numeric_hostname = testname
      record.name_with_blank            = testname
      record.name_with_nil              = testname
      record.valid?.should_not be_truthy
      record.should have_at_least(1).errors_on(:name)
      record.should have_at_least(1).errors_on(:name_with_underscores)
      record.should have_at_least(1).errors_on(:name_with_wildcard)
      record.should have_at_least(1).errors_on(:name_with_valid_tld)
      record.should have_at_least(1).errors_on(:name_with_test_tld)
      record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
      record.should have_at_least(1).errors_on(:name_with_blank)
      record.should have_at_least(1).errors_on(:name_with_nil)
    end
  end

  it "should not be valid with hostname labels beginning with a hyphen" do
    record = Record.new :name                       => '-test',
                        :name_with_underscores      => '-test',
                        :name_with_wildcard         => '-test',
                        :name_with_valid_tld        => '-test.org',
                        :name_with_test_tld         => '-test.test',
                        :name_with_numeric_hostname => '-test',
                        :name_with_blank            => '-test',
                        :name_with_nil              => '-test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should not be valid with hostname labels ending with a hyphen" do
    record = Record.new :name                       => 'test-',
                        :name_with_underscores      => 'test-',
                        :name_with_wildcard         => 'test-',
                        :name_with_valid_tld        => 'test-.org',
                        :name_with_test_tld         => 'test-.test',
                        :name_with_numeric_hostname => 'test-',
                        :name_with_blank            => 'test-',
                        :name_with_nil              => 'test-'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_numeric_hostname)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should not be valid hostnames with numeric only hostname labels" do
    record = Record.new :name                       => '12345',
                        :name_with_underscores      => '12345',
                        :name_with_wildcard         => '12345',
                        :name_with_valid_tld        => '12345.org',
                        :name_with_test_tld         => '12345.test',
                        :name_with_numeric_hostname => '0x12345',
                        :name_with_blank            => '12345',
                        :name_with_nil              => '12345'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
    record.should have_at_least(1).errors_on(:name_with_underscores)
    record.should have_at_least(1).errors_on(:name_with_wildcard)
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
    record.should have_at_least(1).errors_on(:name_with_test_tld)
    record.should have_at_least(1).errors_on(:name_with_blank)
    record.should have_at_least(1).errors_on(:name_with_nil)
  end

  it "should be valid hostnames with numeric only hostname labels if option is true" do
    record = Record.new :name_with_numeric_hostname => '12345',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid hostnames with invalid tld if option is true" do
    record = Record.new :name_with_valid_tld        => 'test.invalidtld',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name_with_valid_tld)
  end

  it "should be valid hostnames with valid tld if option is true" do
    record = Record.new :name_with_valid_tld        => 'test.org',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should be valid hostnames with invalid tld if option is false" do
    record = Record.new :name                       => 'test.invalidtld',
                        :name_with_underscores      => 'test.invalidtld',
                        :name_with_wildcard         => 'test.invalidtld',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test.invalidtld',
                        :name_with_blank            => 'test.invalidtld',
                        :name_with_nil              => 'test.invalidtld'
    record.valid?.should be_truthy
  end

  it "should be valid hostnames with tld from list" do
    record = Record.new :name_with_test_tld         => 'test.test',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid hostnames with invalid tld from list" do
    record = Record.new :name_with_test_tld         => 'test.invalidtld',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name_with_test_tld)
  end

  it "should not be valid domainnames with single numeric hostname labels" do
    record = Record.new :domainname_with_numeric_hostname => '12345',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:domainname_with_numeric_hostname)
  end

  it "should be valid domainnames with numeric hostname labels" do
    record = Record.new :domainname_with_numeric_hostname => '12345.org',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid hostnames containing consecutive dots" do
    record = Record.new :name                       => 'te...st',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name)
  end

  it "should be valid hostnames with trailing dot if option is true" do
    record = Record.new :name_with_valid_root_label => 'test.org.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid hostnames with trailing dot if option is false" do
    record = Record.new :name_with_invalid_root_label => 'test.org.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name_with_invalid_root_label)
  end

  it "should be valid hostnames consisting of a single dot if option is true" do
    record = Record.new :name_with_valid_root_label => '.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid hostnames consisting of a single dot" do
    record = Record.new :name_with_invalid_root_label => '.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:name_with_invalid_root_label)
  end

  it "should be valid domainnames consisting of a single dot if option is true" do
    record = Record.new :domainname_with_valid_root_label => '.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should be_truthy
  end

  it "should not be valid domainnames consisting of a single dot" do
    record = Record.new :domainname_with_invalid_root_label => '.',
                        :name                       => 'test',
                        :name_with_underscores      => 'test',
                        :name_with_wildcard         => 'test',
                        :name_with_valid_tld        => 'test.org',
                        :name_with_test_tld         => 'test.test',
                        :name_with_numeric_hostname => 'test',
                        :name_with_blank            => 'test',
                        :name_with_nil              => 'test'
    record.valid?.should_not be_truthy
    record.should have_at_least(1).errors_on(:domainname_with_invalid_root_label)
  end


end
