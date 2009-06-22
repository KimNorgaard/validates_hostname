# validates\_as\_hostname #

Extension to ActiveRecord::Base for validating hostnames and domain names.

Author: Kim Nørgaard [<jasen@jasen.dk>](mailto:jasen@jasen.dk)

Validates:

* maximum length of hostname is 255 characters
* maximum length of each hostname label is 63 characters
* characters allowed in hostname labels are a-z, A-Z, 0-9 and hyphen
* labels do not begin or end with a hyphen
* labels do not consist of numeric values only

## Options: ##

* option to allow underscores in hostname labels
* option to require that the last label is a valid TLD (ie. require that the name is a FQDN)
* option to allow numeric values in the first label of the hostname (exception: the hostname cannot consist of a single numeric label)
* option to specify a list of valid TLDs

See also [http://www.zytrax.com/books/dns/apa/names.html](http://www.zytrax.com/books/dns/apa/names.html)

## How to install ##

	gem install KimNorgaard-validates_as_hostname --source http://gems.github.com
	OR
	script/plugin install git://github.com/KimNorgaard/validates_as_hostname.git

## How to use ##

	class Record < ActiveRecord::Base
      validates_as_hostname :hostname, OPTIONS
	end

OPTIONS and their defaults:

* one of the usual validation options
* :allow_underscore => false
* :require\_valid\_tld => false
* :valid\_tlds => Array of allowed TLDs (can only be used with :require\_fqdn => true)
* :allow\_numeric\_hostname => false

Examples:

	class Record < ActiveRecord::Base
	  validates_as_hostname :hostname
	end

	>> @record = Record.new :hostname => 'horse'
	>> @record.save
	=> true

	>> @record2 = Record.new :hostname => '_horse'
	>> @record2.save
	=> false

	class Record < ActiveRecord::Base
	  validates_as_hostname :hostname, :allow_underscore => true
	end

	>> @record3 = Record.new :hostname => '_horse'
	>> @record3.save
	=> true


	class Record < ActiveRecord::Base
	  validates_as_hostname :hostname, :require_valid_tld => true
	end

	>> @record4 = Record.new :hostname => 'horse'
	>> @record4.save
	=> false

	>> @record5 = Record.new :hostname => 'horse.com'
	>> @record5.save
	=> true


	class Record < ActiveRecord::Base
	  validates_as_hostname :hostname, :require_valid_tld, :valid_tlds => %w(com org net)
	end

	>> @record6 = Record.new :hostname => 'horse.info'
	>> @record6.save
	=> false


	class Record < ActiveRecord::Base
	  validates_as_hostname :hostname, :allow_numeric_hostname => false
	end

	>> @record7 = Record.new :hostname => '123.info'
	>> @record7.save
	=> false

## Extra validators ##
A few extra validators are included:

### validates\_as\_domainname ###

* sets require\_valid\_tld      => true
* sets allow\_numeric\_hostname => true
* returns error if there is only one label and this label is numeric

### validates\_as\_fqdn ###

* sets require\_valid\_tld      => true

## Error messages ##
Error messages are internationalized using I18n.

Locale variables and their default:

	validates_as_hostname.invalid_label_length: "label must be between 1 and 63 characters long"
	validates_as_hostname.label_begins_or_ends_with_hyphen: "label begins or ends with a hyphen"
	validates_as_hostname.hostname_label_is_numeric: "unqualified hostname part cannot consist of numeric values only"
	validates_as_hostname.single_numeric_hostname_label: "hostnames cannot consist of a single numeric label"
	validates_as_hostname.label_contains_invalid_characters: "label contains invalid characters (valid characters: [LIST])"
	validates_as_hostname.invalid_hostname_length: "hostname must be between 1 and 255 characters long"
	validates_as_hostname.tld_is_invalid: "tld of hostname is invalid"

