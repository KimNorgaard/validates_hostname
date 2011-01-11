class IpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, options[:message] || :ip) unless
      value =~ /^
                (
                  (
                    (([0-9a-fA-F]+:){7}[0-9a-fA-F]+)|
                    (([0-9a-fA-F]+:)*[0-9a-fA-F]+)?::(([0-9a-fA-F]+:)*[0-9a-fA-F]+)?
                  )|
                  (
                    (25[0-5]|2[0-4][\d]|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}
                  )
                )
               $/x
  end
end
