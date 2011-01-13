class Record < ActiveRecord::Base
  validates :name,
            :hostname => true
  validates :name_with_underscores,
            :hostname => { :allow_underscore => true }
  validates :name_with_numeric_hostname,
            :hostname => { :allow_numeric_hostname => true }
  validates :name_with_blank,
            :hostname => true,
            :allow_blank => true
  validates :name_with_nil,
            :hostname => true,
            :allow_nil => true
  validates :name_with_valid_tld,
            :hostname => { :require_valid_tld => true }
  validates :name_with_test_tld,
            :hostname => { :require_valid_tld => true, :valid_tlds => %w(test) }

  validates :domainname_with_numeric_hostname,
            :domainname => true,
            :allow_nil => true,
            :allow_blank => true
end