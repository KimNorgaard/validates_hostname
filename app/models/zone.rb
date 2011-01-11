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
  validates :master,    :ip => true,
                        :unless => 'zone_type.name == "SLAVE"',
                        :allow_nil => true
  
  # RFC 1035, 3.3.13: SOA serial that must be a 32 bit unsigned integer
  validates_numericality_of :serial,
    :greater_than_or_equal_to => 0,
    :less_than => 2**32
  
  # RFC 1035, 3.3.13: SOA refresh, retry, expire, minimum must be 32 bit signed integers
  validates_numericality_of :refresh, :retry, :expire,
    :greater_than_or_equal_to => -(2**31),
    :less_than => 2**31
  
  # RFC 2308, 5: SOA minimum should be between one and three hours
  validates_numericality_of :minimum,
    :greater_than_or_equal_to => 3600,
    :less_than_or_equal_to    => 10800
end
