# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'validates_hostname' do
  let(:test_class) do
    Class.new do
      include ActiveModel::Validations
      attr_accessor :hostname

      # This is necessary for ActiveModel to work with an anonymous class
      def self.model_name
        ActiveModel::Name.new(self, nil, "TestModel")
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

    it_behaves_like 'an invalid hostname', '_example.com'
    it_behaves_like 'an invalid hostname', 'example-.com'
    it_behaves_like 'an invalid hostname', '-example.com'
    it_behaves_like 'an invalid hostname', 'example..com'
    it_behaves_like 'an invalid hostname', 'example.com.'
    it_behaves_like 'an invalid hostname', '12345.com'
    it_behaves_like 'an invalid hostname', '*.example.com'
    it_behaves_like 'a valid hostname', 'a'
    it_behaves_like 'an invalid hostname', 'a' * 256
  end

  describe 'FQDN validation' do
    before { test_class.validates :hostname, fqdn: true }

    it_behaves_like 'a valid hostname', 'example.com'
    it_behaves_like 'an invalid hostname', 'example'
  end

  describe 'Wildcard validation' do
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
