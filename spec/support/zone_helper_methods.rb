module ZoneHelperMethods
  def check_int_on_zone(zone_attrs, attr_name, bad_values, good_values)
    zone = Zone.new(zone_attrs)
    bad_values.each do |v|
      zone.send(attr_name+"=", v)
      zone.should_not be_valid
      zone.should have(1).errors_on(attr_name.to_sym)
    end
    good_values.each do |v|
      zone.send(attr_name+"=", v)
      zone.should be_valid
    end
  end
end