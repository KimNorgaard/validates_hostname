# frozen_string_literal: true

require 'active_model'
require 'set'
require_relative 'validates_hostname/version'

# List from IANA: http://www.iana.org/domains/root/db/
#                 http://data.iana.org/TLD/tlds-alpha-by-domain.txt
tlds_file_path = File.expand_path('../data/tlds.txt', __dir__)
ALLOWED_TLDS = Set.new(File.readlines(tlds_file_path)
                       .map(&:strip)
                       .map(&:downcase)
                       .reject { |line| line.start_with?('#') || line.empty? })
                       .add('.')
                       .freeze

# Validates hostnames.
class HostnameValidator < ActiveModel::EachValidator

  # @param [Hash] options
  # @option options [Boolean] :allow_underscore (false) Allows underscores in hostname labels.
  # @option options [Boolean] :require_valid_tld (false) Requires the hostname to have a valid TLD.
  # @option options [Array<String>] :valid_tlds (ALLOWED_TLDS) A list of valid TLDs.
  # @option options [Boolean] :allow_numeric_hostname (false) Allows numeric-only hostname labels.
  # @option options [Boolean] :allow_wildcard_hostname (false) Allows wildcard hostnames.
  # @option options [Boolean] :allow_root_label (false) Allows a trailing dot.
  def initialize(options)
    super({
      allow_underscore: false,
      require_valid_tld: false,
      valid_tlds: ALLOWED_TLDS,
      allow_numeric_hostname: false,
      allow_wildcard_hostname: false,
      allow_root_label: false
    }.merge(options))
  end

  # Validates the hostname.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [String] value The value to validate.
  def validate_each(record, attribute, value)
    value = value.to_s
    labels = value.split('.')

    validate_hostname_length(record, attribute, value)
    # CHECK 1: hostname label cannot be longer than 63 characters
    validate_label_length(record, attribute, labels)
    # CHECK 2: hostname label cannot begin or end with hyphen
    validate_label_hyphens(record, attribute, labels)
    # CHECK 3: hostname can only contain valid characters
    validate_label_characters(record, attribute, labels)
    # CHECK 4: the unqualified hostname portion cannot consist of numeric values only
    validate_numeric_hostname(record, attribute, labels)
    # CHECK 5: TLD must be valid if required
    handle_tld_validation(record, attribute, value, labels)
    # CHECK 6: hostname may not contain consecutive dots
    validate_consecutive_dots(record, attribute, value)
    # CHECK 7: do not allow trailing dot unless option is set
    validate_trailing_dot(record, attribute, value)
  end

  private

  # Validates the length of the hostname.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [String] value The value to validate.
  def validate_hostname_length(record, attribute, value)
    if value.length == 1 && value != '.'
      add_error(record, attribute, :invalid_hostname_length)
    end

    # maximum hostname length: 255 characters
    unless value.length.between?(1, 255)
      add_error(record, attribute, :invalid_hostname_length)
    end
  end

  # Validates the length of each label in the hostname.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [Array<String>] labels The labels to validate.
  def validate_label_length(record, attribute, labels)
    labels.each do |label|
      unless label.length.between?(1, 63)
        add_error(record, attribute, :invalid_label_length)
      end
    end
  end

  # Validates that no label begins or ends with a hyphen.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [Array<String>] labels The labels to validate.
  def validate_label_hyphens(record, attribute, labels)
    labels.each do |label|
      if label.start_with?('-') || label.end_with?('-')
        add_error(record, attribute, :label_begins_or_ends_with_hyphen)
      end
    end
  end

  # Validates the characters in each label of the hostname.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [Array<String>] labels The labels to validate.
  def validate_label_characters(record, attribute, labels)
    labels.each_with_index do |label, index|
      next if options[:allow_wildcard_hostname] && label == '*' && index.zero?

      valid_chars = 'a-z0-9\-'
      valid_chars += '_' if options[:allow_underscore]
      unless label.match?(/^[#{valid_chars}]+$/i)
        add_error(record, attribute, :label_contains_invalid_characters, valid_chars: valid_chars.delete('\\'))
      end
    end
  end

  # Validates that the hostname is not numeric.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [Array<String>] labels The labels to validate.
  def validate_numeric_hostname(record, attribute, labels)
    if !options[:allow_numeric_hostname] && !labels.empty? && labels.first.match?(/\A\d+\z/)
      add_error(record, attribute, :hostname_label_is_numeric)
    end
  end

  # Validates that the hostname does not contain consecutive dots.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [String] value The value to validate.
  def validate_consecutive_dots(record, attribute, value)
    if value.include?('..')
      add_error(record, attribute, :hostname_contains_consecutive_dots)
    end
  end

  # Validates that the hostname does not end with a dot.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [String] value The value to validate.
  def validate_trailing_dot(record, attribute, value)
    if !options[:allow_root_label] && value.end_with?('.')
      add_error(record, attribute, :hostname_ends_with_dot)
    end
  end

  # Handles the TLD validation.
  #
  # @param [ActiveModel::Base] record The record to validate.
  # @param [Symbol] attribute The attribute to validate.
  # @param [String] value The value to validate.
  # @param [Array<String>] labels The labels to validate.
  def handle_tld_validation(record, attribute, value, labels)
    require_valid_tld = options[:require_valid_tld]
    require_valid_tld = record.send(require_valid_tld) if require_valid_tld.is_a?(Symbol)

    return unless require_valid_tld

    tld = (value == '.' ? value : labels.last) || ''
    return if options[:valid_tlds].any? { |v| v.casecmp?(tld) }

    add_error(record, attribute, :hostname_is_not_fqdn)
  end

  # Adds an error to the record.
  #
  # @param [ActiveModel::Base] record The record to add the error to.
  # @param [Symbol] attr_name The attribute to add the error to.
  # @param [Symbol] message The error message.
  # @param [Hash] interpolators The interpolators for the error message.
  def add_error(record, attr_name, message, interpolators = {})
    args = {
      scope: %i[errors messages]
    }.merge(interpolators)
    record.errors.add(attr_name, I18n.t(message, **args))
  end
end

# Validates domain names.
class DomainnameValidator < HostnameValidator
  def initialize(options)
    super({ require_valid_tld: true, allow_numeric_hostname: true }.merge(options))
  end

  def validate_each(record, attribute, value)
    super

    return unless value.is_a?(String)

    labels = value.split('.')
    # CHECK 1: if there is only one label it cannot be numeric
    if labels.first.match?(/\A\d+\z/) && labels.size == 1
      add_error(record, attribute, :single_numeric_hostname_label)
    end
  end
end

# Validates fully qualified domain names.
class FqdnValidator < HostnameValidator
  def initialize(options)
    super({ require_valid_tld: true }.merge(options))
  end
end

# Validates wildcard hostnames.
class WildcardValidator < HostnameValidator
  def initialize(options)
    super({ allow_wildcard_hostname: true }.merge(options))
  end
end

if defined?(Rails)
  module ValidatesHostname
    class Railtie < Rails::Railtie
      initializer 'validates_hostname.i18n' do
        I18n.load_path += Dir[File.expand_path("../config/locales/*.yml", __dir__)]
      end
    end
  end
end
