require 'rubygems'
gem 'activerecord'
require 'active_record'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/validates_hostname'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Record < ActiveRecord::Base
  validates_as_hostname :hostname
  validates_as_hostname :hostname_with_underscores,
                        :allow_underscore => true
  validates_as_hostname :hostname_with_numeric_hostname,
                        :allow_numeric_hostname => true
  validates_as_hostname :hostname_with_blank,
                        :allow_blank => true
  validates_as_hostname :hostname_with_nil,
                        :allow_nil => true
  validates_as_hostname :hostname_with_valid_tld,
                        :require_valid_tld => true
  validates_as_hostname :hostname_with_test_tld,
                        :require_valid_tld => true,
                        :valid_tlds => %w(test)

  validates_as_domainname :domainname_with_numeric_hostname,
                          :allow_nil => true,
                          :allow_blank => true
end

class ValidatesAsHostnameTest < Test::Unit::TestCase
  
  def setup
    ActiveRecord::Base.connection.tables.each { |table| ActiveRecord::Base.connection.drop_table(table) }
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(:version => 1) do
        create_table :records do |t|
          t.string   :hostname
          t.string   :hostname_with_underscores
          t.string   :hostname_with_valid_tld
          t.string   :hostname_with_test_tld
          t.string   :hostname_with_numeric_hostname
          t.string   :hostname_with_blank
          t.string   :hostname_with_nil
          t.string   :domainname_with_numeric_hostname
        end
      end
    end
  end
  
  def test_should_save_with_valid_hostnames
    @record = Record.new :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end
  
  
  def test_should_save_with_hostnames_with_hyphens
    @record = Record.new :hostname                       => 't-est',
                         :hostname_with_underscores      => 't-est',
                         :hostname_with_valid_tld        => 't-est.org',
                         :hostname_with_test_tld         => 't-test.test',
                         :hostname_with_numeric_hostname => 't-est',
                         :hostname_with_blank            => 't-est',
                         :hostname_with_nil              => 't-est'
    assert @record.save
  end

  def test_should_save_with_hostnames_with_underscores_if_option_is_true
    @record = Record.new :hostname_with_underscores      => '_test',
                         :hostname                       => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end

  def test_should_not_save_with_hostnames_with_underscores_if_option_is_false
    @record = Record.new :hostname_with_underscores      => '_test',
                         :hostname                       => '_test',
                         :hostname_with_valid_tld        => '_test.org',
                         :hostname_with_test_tld         => '_test.test',
                         :hostname_with_numeric_hostname => '_test',
                         :hostname_with_blank            => '_test',
                         :hostname_with_nil              => '_test'
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_numeric_hostname)
    assert @record.errors.on(:hostname_with_blank)
    assert @record.errors.on(:hostname_with_nil)
  end

  def test_should_save_with_blank_hostname
    @record = Record.new :hostname_with_blank            => '',
                         :hostname                       => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end

  def test_should_not_save_with_blank_hostname
    @record = Record.new :hostname                       => '',
                         :hostname_with_underscores      => '',
                         :hostname_with_valid_tld        => '',
                         :hostname_with_test_tld         => '',
                         :hostname_with_numeric_hostname => '',
                         :hostname_with_nil              => '',
                         :hostname_with_blank            => ''
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_underscores)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_numeric_hostname)
    assert @record.errors.on(:hostname_with_nil)
  end

  def test_should_save_with_nil_hostname
    @record = Record.new :hostname_with_nil              => nil,
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test'
    assert @record.save
  end

  def test_should_not_save_with_too_long_hostname
    longname=('t' * 256)
    @record = Record.new :hostname                       => longname,
                         :hostname_with_underscores      => longname,
                         :hostname_with_valid_tld        => longname + ".org",
                         :hostname_with_test_tld         => longname + ".test",
                         :hostname_with_numeric_hostname => longname,
                         :hostname_with_blank            => longname,
                         :hostname_with_nil              => longname
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_underscores)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_numeric_hostname)
    assert @record.errors.on(:hostname_with_blank)
    assert @record.errors.on(:hostname_with_nil)
  end

  def test_should_not_save_with_too_long_hostname_label
    long_labels = (('t' * 64) + '.' + ('t' * 64))
    @record = Record.new :hostname                       => long_labels,
                         :hostname_with_underscores      => long_labels,
                         :hostname_with_valid_tld        => long_labels + ".org",
                         :hostname_with_test_tld         => long_labels + ".test",
                         :hostname_with_numeric_hostname => long_labels,
                         :hostname_with_blank            => long_labels,
                         :hostname_with_nil              => long_labels
    assert !@record.save
    assert @record.errors.on(:hostname)
  end
  
  def test_shold_not_save_with_invalid_characters
    @record = Record.new
    %w( ; : * ^ ~ + ' ! # " % & / ( ) = ? $ \\ ).each do |char|
      testname="#{char}test"
      @record.hostname                       = testname
      @record.hostname_with_underscores      = testname
      @record.hostname_with_valid_tld        = testname + ".org"
      @record.hostname_with_test_tld         = testname + '.test'
      @record.hostname_with_numeric_hostname = testname
      @record.hostname_with_blank            = testname
      @record.hostname_with_nil              = testname
      assert !@record.save
      assert @record.errors.on(:hostname)
      assert @record.errors.on(:hostname_with_underscores)
      assert @record.errors.on(:hostname_with_valid_tld)
      assert @record.errors.on(:hostname_with_test_tld)
      assert @record.errors.on(:hostname_with_numeric_hostname)
      assert @record.errors.on(:hostname_with_blank)
      assert @record.errors.on(:hostname_with_nil)
    end
  end

  def test_should_not_save_with_hostname_labels_beginning_with_a_hyphen
    @record = Record.new :hostname                       => '-test',
                         :hostname_with_underscores      => '-test',
                         :hostname_with_valid_tld        => '-test.org',
                         :hostname_with_test_tld         => '-test.test',
                         :hostname_with_numeric_hostname => '-test',
                         :hostname_with_blank            => '-test',
                         :hostname_with_nil              => '-test'
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_underscores)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_numeric_hostname)
    assert @record.errors.on(:hostname_with_blank)
    assert @record.errors.on(:hostname_with_nil)
  end

  def test_should_not_save_with_hostname_labels_ending_with_a_hyphen
    @record = Record.new :hostname                       => 'test-',
                         :hostname_with_underscores      => 'test-',
                         :hostname_with_valid_tld        => 'test-.org',
                         :hostname_with_test_tld         => 'test-.test',
                         :hostname_with_numeric_hostname => 'test-',
                         :hostname_with_blank            => 'test-',
                         :hostname_with_nil              => 'test-'
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_underscores)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_numeric_hostname)
    assert @record.errors.on(:hostname_with_blank)
    assert @record.errors.on(:hostname_with_nil)
  end

  def test_should_not_save_hostnames_with_numeric_only_hostname_labels
    @record = Record.new :hostname                       => '12345',
                         :hostname_with_underscores      => '12345',
                         :hostname_with_valid_tld        => '12345.org',
                         :hostname_with_test_tld         => '12345.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => '12345',
                         :hostname_with_nil              => '12345'
    assert !@record.save
    assert @record.errors.on(:hostname)
    assert @record.errors.on(:hostname_with_underscores)
    assert @record.errors.on(:hostname_with_valid_tld)
    assert @record.errors.on(:hostname_with_test_tld)
    assert @record.errors.on(:hostname_with_blank)
    assert @record.errors.on(:hostname_with_nil)
  end
  
  def test_should_save_hostnames_with_numeric_only_hostname_labels_if_option_is_true
    @record = Record.new :hostname_with_numeric_hostname => '12345',
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end
  
  def test_should_not_save_hostnames_with_invalid_tld_if_option_is_true
    @record = Record.new :hostname_with_valid_tld        => 'test.invalidtld',
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert !@record.save
    assert @record.errors.on(:hostname_with_valid_tld)
  end
  
  def test_should_save_hostnames_with_valid_tld_if_option_is_true
    @record = Record.new :hostname_with_valid_tld        => 'test.org',
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end
  
  def test_should_save_hostnames_with_invalid_tld_if_option_is_false
    @record = Record.new :hostname                       => 'test.invalidtld',
                         :hostname_with_underscores      => 'test.invalidtld',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_test_tld         => 'test.test',
                         :hostname_with_numeric_hostname => 'test.invalidtld',
                         :hostname_with_blank            => 'test.invalidtld',
                         :hostname_with_nil              => 'test.invalidtld'
    assert @record.save
  end
  
  def test_should_save_hostnames_with_tld_from_list
    @record = Record.new :hostname_with_test_tld         => 'test.test',
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert @record.save
  end
  
  def test_should_not_save_hostnames_with_invalid_tld_from_list
    @record = Record.new :hostname_with_test_tld         => 'test.invalidtld',
                         :hostname                       => 'test',
                         :hostname_with_underscores      => 'test',
                         :hostname_with_valid_tld        => 'test.org',
                         :hostname_with_numeric_hostname => 'test',
                         :hostname_with_blank            => 'test',
                         :hostname_with_nil              => 'test'
    assert !@record.save
    assert @record.errors.on(:hostname_with_test_tld)
  end
  
  def test_should_not_save_domainnames_with_single_numeric_hostname_labels
    @record = Record.new :domainname_with_numeric_hostname => '12345',
                         :hostname                         => 'test',
                         :hostname_with_underscores        => 'test',
                         :hostname_with_valid_tld          => 'test.org',
                         :hostname_with_test_tld           => 'test.test',
                         :hostname_with_numeric_hostname   => 'test',
                         :hostname_with_blank              => 'test',
                         :hostname_with_nil                => 'test'
    assert !@record.save
    assert @record.errors.on(:domainname_with_numeric_hostname)
  end

  def test_should_save_domainnames_with_numeric_hostname_labels
    @record = Record.new :domainname_with_numeric_hostname => '12345.org',
                         :hostname                         => 'test',
                         :hostname_with_underscores        => 'test',
                         :hostname_with_valid_tld          => 'test.org',
                         :hostname_with_test_tld           => 'test.test',
                         :hostname_with_numeric_hostname   => 'test',
                         :hostname_with_blank              => 'test',
                         :hostname_with_nil                => 'test'
    assert @record.save
  end
end