class Record
  include ActiveModel::Model
  include ActiveModel::Validations
  
  # Convenience method hosited from rspec-railsa
  def errors_on(attribute, options = {})
    self.valid?(options[:context])
    [self.errors[attribute]].flatten.compact
  end
  
  attr_accessor :name
  validates :name,
            :hostname => true

  attr_accessor :name_with_underscores
  validates :name_with_underscores,
            :hostname => { :allow_underscore => true }

  attr_accessor :name_with_wildcard
  validates :name_with_wildcard,
            :hostname => { :allow_wildcard_hostname => true }

  attr_accessor :name_with_numeric_hostname
  validates :name_with_numeric_hostname,
            :hostname => { :allow_numeric_hostname => true }

  attr_accessor :name_with_blank
  validates :name_with_blank,
            :hostname => true,
            :allow_blank => true

  attr_accessor :name_with_nil
  validates :name_with_nil,
            :hostname => true,
            :allow_nil => true

  attr_accessor :name_with_valid_tld
  validates :name_with_valid_tld,
            :hostname => { :require_valid_tld => true }

  attr_accessor :name_with_test_tld
  validates :name_with_test_tld,
            :hostname => { :require_valid_tld => true, :valid_tlds => %w(test) }

  attr_accessor :name_with_valid_root_label
  validates :name_with_valid_root_label,
            :hostname => { :allow_root_label => true },
            :allow_nil => true,
            :allow_blank => true

  attr_accessor :name_with_invalid_root_label
  validates :name_with_invalid_root_label,
            :hostname => true,
            :allow_nil => true,
            :allow_blank => true

  attr_accessor :domainname_with_numeric_hostname
  validates :domainname_with_numeric_hostname,
            :domainname => true,
            :allow_nil => true,
            :allow_blank => true

  attr_accessor :domainname_with_valid_root_label
  validates :domainname_with_valid_root_label,
            :domainname => { :allow_root_label => true },
            :allow_nil => true,
            :allow_blank => true

  attr_accessor :domainname_with_invalid_root_label
  validates :domainname_with_invalid_root_label,
            :domainname => true,
            :allow_nil => true,
            :allow_blank => true
end
