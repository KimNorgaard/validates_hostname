require 'spec_helper'

describe Zone, "that is new" do
  fixtures :zone_types

  before(:each) do
    @valid_attributes = {
      :name      => 'testdomain.com',
      :mname     => 'ns1.somewhereelse.com',
      :rname     => 'hostmaster.somewhereelse.com',
      :serial    => Time.now.to_i,
      :refresh   => 10800,
      :retry     => 3600,
      :expire    => 604800,
      :minimum   => 3600,
      :active    => 1,
      :zone_type => ZoneType.find_by_name("NATIVE")
    }
  end

  it "should create a new instance given valid attributes" do
    Zone.create!(@valid_attributes)
  end
  
  it "should not be valid if the zone already exists" do
    Zone.create!(@valid_attributes)
    zone = Zone.create(@valid_attributes)
    zone.should_not be_valid
  end
  
  it "should not be valid without an name" do
    @valid_attributes[:name] = nil
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:name)
  end

  it "should not be valid without a name server" do
    @valid_attributes[:mname] = nil
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:mname)
  end

  it "should not be valid without a mailbox" do
    @valid_attributes[:rname] = nil
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:rname)
  end
  
  it "should not be valid if zone type is SLAVE but does not have a master set" do
    @valid_attributes[:master] = nil
    @valid_attributes[:zone_type] = ZoneType.find_by_name("SLAVE")
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:master)
  end
  
  it "should not be valid if master is not a valid ip address" do
    @valid_attributes[:master] = "hestetis"
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:master)
    zone.master = '127.0.0.1'
    zone.should be_valid
    zone.master = '127..0.0.1'
    zone.should_not be_valid
    zone.master = '999.999.999.999'
    zone.should_not be_valid
    zone.master = '999'
    zone.should_not be_valid    
    zone.master = '3XXX:1900:4545:3:200:f8ff:fe21:67cf'
    zone.should_not be_valid
    zone.master = '3ffe:1900:4545:3:200:f8ff:fe21:67cf'
    zone.should be_valid
    zone.master = 'fe80:0:0:0:200:f8ff:fe21:67cf'
    zone.should be_valid
    zone.master = 'fe80::200:f8ff:fe21:67cf'
    zone.should be_valid
  end
  
  it "should not be valid if SOA serial is not an unsigned 32 bit integer" do
    @valid_attributes[:serial] = -1
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:serial)
    zone.serial = 1
    zone.should be_valid
    zone.serial = 2**32-1
    zone.should be_valid
    zone.serial = 2**32
    zone.should_not be_valid
    zone.should have(1).errors_on(:serial)
  end

  it "should not be valid if SOA refresh value is not an unsigned 32 bit integer" do
    @valid_attributes[:refresh] = -(2**31)-1
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:refresh)
    zone.refresh = -(2**31)
    zone.should be_valid
    zone.refresh = 2**31-1
    zone.should be_valid
    zone.refresh = 2**31
    zone.should_not be_valid
    zone.should have(1).errors_on(:refresh)
  end

  it "should not be valid if SOA retry value is not an unsigned 32 bit integer" do
    @valid_attributes[:retry] = -(2**31)-1
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:retry)
    zone.retry = -(2**31)
    zone.should be_valid
    zone.retry = 2**31-1
    zone.should be_valid
    zone.retry = 2**31
    zone.should_not be_valid
    zone.should have(1).errors_on(:retry)
  end

  it "should not be valid if SOA expire value is not an unsigned 32 bit integer" do
    @valid_attributes[:expire] = -(2**31)-1
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:expire)
    zone.expire = -(2**31)
    zone.should be_valid
    zone.expire = 2**31-1
    zone.should be_valid
    zone.expire = 2**31
    zone.should_not be_valid
    zone.should have(1).errors_on(:expire)
  end
  
  it "should not be valid if SOA minimum TTL is not an unsigned integer between 3600 and 10800" do
    @valid_attributes[:minimum] = 3599
    zone = Zone.new(@valid_attributes)
    zone.should_not be_valid
    zone.should have(1).errors_on(:minimum)
    zone.minimum = 3600
    zone.should be_valid
    zone.minimum = 10800
    zone.should be_valid
    zone.minimum = 10801
    zone.should_not be_valid
    zone.should have(1).errors_on(:minimum)
  end

end

describe Zone, "that exists" do
  fixtures :zones
  fixtures :zone_types
  
  it "should have a collection of zones" do
    Zone.find(:all).should_not be_empty
  end

  it "should have three records" do
    Zone.should have(3).records
  end
  
  it "should find an existing zone" do
    zone = Zone.find(zones("test.com".to_sym).id)
    zone.should eql(zones("test.com".to_sym))
  end
end

describe Zone, "with Zone Types" do
  fixtures :zone_types
  fixtures :zones
  
  it "should have a zone type" do
    zone = Zone.find(zones("test.com".to_sym).id)
    zone.zone_type.should_not be_nil
  end
end