# ValidatesHostname

[![Gem Version](https://badge.fury.io/rb/validates_hostname.svg)](https://badge.fury.io/rb/validates_hostname)
[![CI](https://github.com/KimNorgaard/validates_hostname/actions/workflows/ci.yml/badge.svg)](https://github.com/KimNorgaard/validates_hostname/actions/workflows/ci.yml)

## Description

Extension to ActiveModel for validating hostnames and domain names.

## Requirements

- Ruby >= 3.0.0
- Active Model >= 6.0

## Features

- Adds validation for hostnames to ActiveModel
- Supports I18n for the error messages

## Installation

As a gem:

```bash
# in Gemfile
gem 'validates_hostname', '~> 2.0'

# Run bundler
bundle install
```

## Validations Performed

The following validations are performed on the hostname:

- The maximum length of the hostname is 255 characters.
- The maximum length of each hostname label is 63 characters.
- The allowed characters in hostname labels are `a-z`, `A-Z`, `0-9` and hyphen (`-`).
- Labels do not begin or end with a hyphen.
- Labels do not consist of numeric values only.

## Options

The validator can be configured with the following options:

- `allow_underscore`: Allows for underscores in hostname labels.
- `require_valid_tld`: Requires that the last label is a valid TLD.
- `valid_tlds`: A list of valid TLDs. This option requires `require_valid_tld` to be `true`.
- `allow_numeric_hostname`: Allows numeric values in the first label of the hostname.
- `allow_wildcard_hostname`: Allows for a wildcard hostname in the first label.
- `allow_root_label`: Allows for a trailing dot (root label) in the hostname.

See also http://www.zytrax.com/books/dns/apa/names.html

## How to Use

Simple usage:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: true
end
```

With options:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { allow_underscore: true }
end
```

## Options and Their Defaults

- `allow_underscore`: Permits underscore characters (`_`) in hostname labels. (default: `false`)
- `require_valid_tld`: Ensures that the hostname's last label is a recognized Top-Level Domain (TLD). (default: `false`)
- `valid_tlds`: An array of specific Top-Level Domains (TLDs) that are considered valid. This option requires `require_valid_tld` to be `true` to take effect. (default: List from `data/tlds.txt`)
- `allow_numeric_hostname`: Allows hostname labels to consist solely of numeric digits (e.g., `123.example.com`). Note: A hostname cannot consist of a single numeric label (e.g., `123` is always invalid). (default: `false`)
- `allow_wildcard_hostname`: Permits a wildcard character (`*`) as the first label of the hostname (e.g., `*.example.com`). (default: `false`)
- `allow_root_label`: Permits a trailing dot (root label) in the hostname (e.g., `example.com.`). (default: `false`)

## Examples

Without options:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: true
end

>> @record = Record.new(name: "horse")
>> @record.save
=> true

>> @record2 = Record.new(name: "_horse")
>> @record2.save
=> false
```

With `:allow_underscore`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { allow_underscore: true }
end

>> @record3 = Record.new(name: "_horse")
>> @record3.save
=> true
```

With `:require_valid_tld`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { require_valid_tld: true }
end

>> @record4 = Record.new(name: "horse")
>> @record4.save
=> false

>> @record5 = Record.new(name: "horse.com")
>> @record5.save
=> true
```

With `:valid_tlds`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { require_valid_tld: true, valid_tlds: %w(com org net) }
end

>> @record6 = Record.new(name: "horse.info")
>> @record6.save
=> false
```

With `:allow_numeric_hostname`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { allow_numeric_hostname: false }
end

>> @record7 = Record.new(name: "123.info")
>> @record7.save
=> false
```

With `:allow_wildcard_hostname`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { allow_wildcard_hostname: true }
end

>> @record8 = Record.new(name: "*.123.info")
>> @record8.save
=> true
```

With `:allow_root_label`:

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, hostname: { allow_root_label: true }
end

>> @record9 = Record.new(name: "example.com.")
>> @record9.save
=> true
```

## Extra Validators

A few extra validators are included.

### domainname

Sets `require_valid_tld` to `true`.

Sets `allow_numeric_hostname` to `true`. This option cannot be changed by the user.

Returns error if there is only one label and this label is numeric.

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, domainname: true
end

>> @record = Record.new(name: "123.com")
>> @record.save
=> true

>> @record2 = Record.new(name: "123")
>> @record2.save
=> false
```

### fqdn

Sets `require_valid_tld` to `true`.

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, fqdn: true
end

>> @record = Record.new(name: "example.com")
>> @record.save
=> true

>> @record2 = Record.new(name: "example")
>> @record2.save
=> false
```

### wildcard

Sets `allow_wildcard_hostname` to `true`.

```ruby
class Record
  include ActiveModel::Validations
  attr_accessor :name

  def self.model_name
    ActiveModel::Name.new(self, nil, "Record")
  end

  validates :name, wildcard: true
end

>> @record = Record.new(name: "*.example.com")
>> @record.save
=> true
```

## Error Messages

The gem uses the I18n system for error messages. You can provide your own
translations in your application's locale files (e.g., `config/locales/en.yml`).

Example of a custom error message in `config/locales/en.yml`:

```yaml
en:
  errors:
    messages:
      invalid_hostname_length: "is not a valid hostname length"
```

The gem comes with the following built-in translations:

- English (en)
- Spanish (es)
- German (de)
- French (fr)
- Simplified Chinese (zh)

The `%{valid_chars}` interpolator is available for the
`label_contains_invalid_characters` message.

## Maintainers

- [Kim Nørgaard](mailto:jasen@jasen.dk)

## License

Copyright (c) 2009-2025 Kim Nørgaard, released under the MIT license.
