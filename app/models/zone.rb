class Zone < ActiveRecord::Base
  belongs_to :zone_type
  
  validates :name,      :presence => true,
                        :uniqueness => true
  validates :mname,     :presence => true
  validates :rname,     :presence => true
  validates :serial,    :presence => true
  validates :refresh,   :presence => true
  validates :retry,     :presence => true
  validates :expire,    :presence => true
  validates :minimum,   :presence => true
  validates :zone_type, :presence => true
  validates :master,    :presence => true,
                        :if => 'zone_type.name == "SLAVE"'

  # Master must be a valid IP address
  validates :master,    :ip => true,
                        :unless => 'zone_type.name == "SLAVE"',
                        :allow_nil => true
  
  # RFC 1035, 3.3.13: SOA serial that must be a 32 bit unsigned integer
  validates_numericality_of :serial,
    :greater_than_or_equal_to => 0,
    :less_than => 2**32,
    :allow_blank => true
  
  # RFC 1035, 3.3.13: SOA refresh, retry, expire, minimum must be 32 bit signed integers
  validates_numericality_of :refresh, :retry, :expire,
    :greater_than_or_equal_to => -(2**31),
    :less_than => 2**31
  
  # RFC 2308, 5: SOA minimum should be between one and three hours
  validates_numericality_of :minimum,
    :greater_than_or_equal_to => 3600,
    :less_than_or_equal_to    => 10800

  # Custom zone validation
  validates :name,  :domainname => true, :allow_blank => true
  validates :mname, :hostname => { :allow_underscore => true }, :allow_blank => true
  validates :rname, :fqdn => true, :allow_blank => true

  # Clear empty attributes before saving
  before_save :clear_empty_attrs
  
  private
  
  def clear_empty_attrs
    if self.master
      self.master = nil if self.master.empty?
    end
  end
end
