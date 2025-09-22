# frozen_string_literal: true

require 'active_model'
require_relative 'validates_hostname/version'

# List from IANA: http://www.iana.org/domains/root/db/
#                 http://data.iana.org/TLD/tlds-alpha-by-domain.txt
tlds_file_path = File.expand_path('../data/tlds.txt', __dir__)
ALLOWED_TLDS = File.readlines(tlds_file_path)
                   .map(&:strip)
                   .map(&:downcase)
                   .reject { |line| line.start_with?('#') || line.empty? }
                   .unshift('.')
                   .freeze

# Validates hostnames.
class HostnameValidator < ActiveModel::EachValidator
  DEFAULT_ERROR_MESSAGES = {
    invalid_hostname_length:            'must be between 1 and 255 characters long',
    invalid_label_length:               'must be between 1 and 63 characters long',
    label_begins_or_ends_with_hyphen:   'begins or ends with hyphen',
    label_contains_invalid_characters:  "contains invalid characters (valid characters: [%{valid_chars}])",
    hostname_label_is_numeric:          'unqualified hostname part cannot consist of numeric values only',
    hostname_is_not_fqdn:               'is not a fully qualified domain name',
    single_numeric_hostname_label:      'cannot consist of a single numeric label',
    hostname_contains_consecutive_dots: 'must not contain consecutive dots',
    hostname_ends_with_dot:             'must not end with a dot'
  }.freeze

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

  def validate_each(record, attribute, value)
    value = value.to_s

    if value.length == 1 && value != '.'
      add_error(record, attribute, :invalid_hostname_length)
    end

    # maximum hostname length: 255 characters
    unless value.length.between?(1, 255)
      add_error(record, attribute, :invalid_hostname_length)
    end

    return unless value.is_a?(String)

    labels = value.split('.')
    labels.each_with_index do |label, index|
      # CHECK 1: hostname label cannot be longer than 63 characters
      unless label.length.between?(1, 63)
        add_error(record, attribute, :invalid_label_length)
      end

      # CHECK 2: hostname label cannot begin or end with hyphen
      if label.start_with?('-') || label.end_with?('-')
        add_error(record, attribute, :label_begins_or_ends_with_hyphen)
      end

      next if options[:allow_wildcard_hostname] && label == '*' && index.zero?

      # CHECK 3: hostname can only contain valid characters
      valid_chars = 'a-z0-9\-'
      valid_chars += '_' if options[:allow_underscore]
      unless label.match?(/^[#{valid_chars}]+$/i)
        add_error(record, attribute, :label_contains_invalid_characters, valid_chars: valid_chars.delete('\\'))
      end
    end

    # CHECK 4: the unqualified hostname portion cannot consist of numeric values only
    if !options[:allow_numeric_hostname] && !labels.empty? && labels.first.match?(/\A\d+\z/)
      add_error(record, attribute, :hostname_label_is_numeric)
    end

    # CHECK 5: TLD must be valid if required
    handle_tld_validation(record, attribute, value, labels)

    # CHECK 6: hostname may not contain consecutive dots
    if value.include?('..')
      add_error(record, attribute, :hostname_contains_consecutive_dots)
    end

    # CHECK 7: do not allow trailing dot unless option is set
    if !options[:allow_root_label] && value.end_with?('.')
      add_error(record, attribute, :hostname_ends_with_dot)
    end
  end

  private

  def handle_tld_validation(record, attribute, value, labels)
    require_valid_tld = options[:require_valid_tld]
    require_valid_tld = record.send(require_valid_tld) if require_valid_tld.is_a?(Symbol)

    return unless require_valid_tld

    tld = (value == '.' ? value : labels.last) || ''
    return if options[:valid_tlds].any? { |v| v.casecmp?(tld) }

    add_error(record, attribute, :hostname_is_not_fqdn)
  end

  def add_error(record, attr_name, message, interpolators = {})
    args = {
      default: [options[:message], DEFAULT_ERROR_MESSAGES[message]].compact,
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
