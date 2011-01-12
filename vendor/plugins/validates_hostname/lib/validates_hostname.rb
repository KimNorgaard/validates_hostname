module ValidatesHostname
  autoload :VERSION, 'validates_hostname/version'



  def validates_as_domainname(*attr_names)
    options = {
      :require_valid_tld        => true,
      :allow_numeric_hostname   => true
    }.merge(attr_names.last.is_a?(Hash) ? attr_names.pop : {})

    validates_as_hostname(*attr_names + [options])
  
    # each +value+ is a full hostname
    # split these into labels and do various checks
    validates_each(attr_names, options) do |r, attr_name, value|
      if value.is_a?(String)
        labels = value.split '.'
        labels.each do |label|
          # CHECK 1: if there is only one label it cannot be numeric even
          #          though numeric hostnames are allowed
          if options[:allow_numeric_hostname] == true
            is_numeric_only = (
              (
                Integer(labels[0]) rescue false
              ) ? true : false
            )
            if is_numeric_only and labels.size == 1
              r.errors.add( attr_name,
                I18n.t(
                  'validates_as_hostname.single_numeric_hostname_label',
                  :default => 'hostnames cannot consist of a single ' \
                            + 'numeric label'
                )
              )
            end
          end
        end
      end
    end
  end


  def validates_as_fqdn(*attr_names)
    options = {
      :require_valid_tld        => true,
    }.merge(attr_names.last.is_a?(Hash) ? attr_names.pop : {})

    validates_as_hostname(*attr_names + [options])
  end


  def validates_as_hostname(*attr_names)
    options = {
      :allow_underscore        => false,
      :require_valid_tld       => false,
      :valid_tlds              => ALLOWED_TLDS,
      :allow_numeric_hostname  => false
    }.merge(attr_names.last.is_a?(Hash) ? attr_names.pop : {})


    # maximum hostname length: 255 characters
    validates_length_of *attr_names + [{
      :in => 1..255,
      :message => I18n.t(
                    'validates_as_hostname.invalid_hostname_length',
                    :default => 'hostname must be between 1 and 255 ' \
                              + 'characters long'
      )
    }.merge(options)]

    # each +value+ is a full hostname
    # split these into labels and do various checks
    validates_each(attr_names, options) do |r, attr_name, value|
      if value.is_a?(String)
        labels = value.split '.'
        labels.each do |label|
          # CHECK 1: hostname label cannot be longer than 63 characters
          if label.length > 63
            r.errors.add( attr_name,
              I18n.t(
                'validates_as_hostname.invalid_label_length',
                :default => 'label must be between 1 and 63 characters ' \
                          + 'long'
              )
            )
          end

          # CHECK 2: hostname label cannot begin or end with hyphen
          if label =~ /^[-]/i or label =~ /[-]$/
            r.errors.add( attr_name,
              I18n.t(
                'validates_as_hostname.label_begins_or_ends_with_hyphen',
                :default => 'label begins or ends with a hyphen'
              )
            )
          end

          # CHECK 3: hostname can only contain characters: 
          #          a-z, 0-9, hyphen, optionally underscore
          valid_chars = 'a-z0-9\-'
          valid_chars << '_' if options[:allow_underscore] == true
          unless label =~ /^[#{valid_chars}]+$/i
            r.errors.add( attr_name,
              I18n.t(
                'validates_as_hostname.label_contains_invalid_characters',
                :default => "label contains invalid characters (valid " \
                          + "characters: [#{valid_chars}])"
              )
            ) 
          end
        end

        # CHECK 4: the unqualified hostname portion cannot consist of 
        #          numeric values only
        if options[:allow_numeric_hostname] == false
          is_numeric_only = (
            (
              Integer(labels[0]) rescue false
            ) ? true : false
          )
          if is_numeric_only
            r.errors.add( attr_name,
              I18n.t(
                'validates_as_hostname.hostname_label_is_numeric',
                :default => 'unqualified hostname part cannot consist ' \
                          + 'of numeric values only'
              )
            )
          end
        end

        # CHECK 5: in order to be fully qualified, the full hostnames
        #          TLD must be valid
        if options[:require_valid_tld] == true
          has_tld = options[:valid_tlds].select {
            |tld| tld =~ /^#{labels.last}$/i
          }.empty? ? false : true
          unless has_tld
            r.errors.add( attr_name,
              I18n.t(
                'validates_as_hostname.hostname_is_not_fqdn',
                :default => 'hostname is not a fully qualified domain name'
              )
            )
          end
        end
      end
    end
  end
end

require 'validates_hostname/validator'