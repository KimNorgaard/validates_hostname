# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HostnameValidator do
  let(:test_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :hostname

      # This is necessary for ActiveModel to work with an anonymous class
      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestModel')
      end
    end
  end

  let(:record) { test_class.new }

  RSpec.shared_examples 'a valid hostname' do |hostname|
    it "is valid with #{hostname}" do
      record.hostname = hostname
      expect(record).to be_valid
    end
  end

  RSpec.shared_examples 'an invalid hostname' do |hostname|
    it "is invalid with #{hostname}" do
      record.hostname = hostname
      expect(record).to be_invalid
    end
  end

  describe 'with default options' do
    before { test_class.validates :hostname, hostname: true }

    it_behaves_like 'a valid hostname', 'example.com'
    it_behaves_like 'a valid hostname', 'example-hyphen.com'
    it_behaves_like 'a valid hostname', 'a'
    it_behaves_like 'a valid hostname', "#{'a' * 63}.com"

    it 'is invalid with underscores' do
      record.hostname = '_example.com'
      expect(record).to be_invalid
    end

    it 'is invalid if a label ends with a hyphen' do
      record.hostname = 'example-.com'
      expect(record).to be_invalid
    end

    it 'is invalid if a label begins with a hyphen' do
      record.hostname = '-example.com'
      expect(record).to be_invalid
    end

    it 'is invalid with consecutive dots' do
      record.hostname = 'example..com'
      expect(record).to be_invalid
    end

    it 'is invalid with a trailing dot' do
      record.hostname = 'example.com.'
      expect(record).to be_invalid
    end

    it 'is invalid with a numeric-only label' do
      record.hostname = '12345.com'
      expect(record).to be_invalid
    end

    it 'is invalid with a wildcard' do
      record.hostname = '*.example.com'
      expect(record).to be_invalid
    end

    it 'is invalid if it is too long (256 chars)' do
      record.hostname = 'a' * 256
      expect(record).to be_invalid
    end

    it 'is invalid if a label is too long (64 chars)' do
      record.hostname = "#{'a' * 64}.com"
      expect(record).to be_invalid
    end

    it 'is invalid with leading/trailing whitespace' do
      record.hostname = ' example.com '
      expect(record).to be_invalid
    end

    it 'is invalid if blank' do
      record.hostname = ''
      expect(record).to be_invalid
    end

    it 'is invalid if nil' do
      record.hostname = nil
      expect(record).to be_invalid
    end

    it 'is invalid if a single dot' do
      record.hostname = '.'
      expect(record).to be_invalid
    end

    it 'is invalid with special characters' do
      %w[; : * ^ ~ + ' ! # " % & / ( ) = ? $ \\].each do |char|
        record.hostname = "#{char}example.com"
        expect(record).to be_invalid
      end
    end
  end

  describe 'with fqdn: true' do
    before { test_class.validates :hostname, fqdn: true }

    it_behaves_like 'a valid hostname', 'example.com'
    it_behaves_like 'an invalid hostname', 'example'
  end

  describe 'with wildcard: true' do
    before { test_class.validates :hostname, wildcard: true }

    it_behaves_like 'a valid hostname', '*.example.com'
  end

  describe 'with allow_underscore: true' do
    before { test_class.validates :hostname, hostname: { allow_underscore: true } }

    it_behaves_like 'a valid hostname', '_example.com'
  end

  describe 'with require_valid_tld: true' do
    before { test_class.validates :hostname, hostname: { require_valid_tld: true } }

    it_behaves_like 'a valid hostname', 'example.com'
    it_behaves_like 'an invalid hostname', 'example.invalidtld'
  end

  describe 'with valid_tlds: %w[test]' do
    before { test_class.validates :hostname, hostname: { require_valid_tld: true, valid_tlds: %w[test] } }

    it_behaves_like 'a valid hostname', 'example.test'
    it_behaves_like 'an invalid hostname', 'example.com'
  end

  describe 'with allow_numeric_hostname: true' do
    before { test_class.validates :hostname, hostname: { allow_numeric_hostname: true } }

    it_behaves_like 'a valid hostname', '12345.com'
  end

  describe 'with allow_wildcard_hostname: true' do
    before { test_class.validates :hostname, hostname: { allow_wildcard_hostname: true } }

    it_behaves_like 'a valid hostname', '*.example.com'
  end

  describe 'with allow_root_label: true' do
    before { test_class.validates :hostname, hostname: { allow_root_label: true } }

    it_behaves_like 'a valid hostname', 'example.com.'
    it_behaves_like 'a valid hostname', '.'
  end

  describe 'domainname validation' do
    before { test_class.validates :hostname, domainname: true }

    it_behaves_like 'a valid hostname', '12345.com'
    it_behaves_like 'an invalid hostname', '12345'
  end

  describe 'I18n' do
    before do
      test_class.validates :hostname, hostname: true
      I18n.locale = :es
    end

    after do
      I18n.locale = :en
    end

    it 'returns the translated error message' do
      record.hostname = '-example.com'
      record.valid?
      expect(record.errors[:hostname]).to include('comienza o termina con un guión')
    end
  end
end
