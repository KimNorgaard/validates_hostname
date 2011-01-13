require 'active_support/concern'
require 'active_model'

module PAK
  module ValidatesHostname
    autoload :VERSION, 'validates_hostname/version'

    # List from IANA: http://www.iana.org/domains/root/db/
    ALLOWED_TLDS = %w(
      ac ad ae aero af ag ai al am an ao aq ar arpa as asia at au aw ax az 
      ba bb bd be bf bg bh bi biz bj bl bm bn bo br bs bt bv bw by bz 
      ca cat cc cd cf cg ch ci ck cl cm cn co com coop cr cu cv cx cy cz 
      de dj dk dm do dz 
      ec edu ee eg eh er es et eu 
      fi fj fk fm fo fr 
      ga gb gd ge gf gg gh gi gl gm gn gov gp gq gr gs gt gu gw gy 
      hk hm hn hr ht hu 
      id ie il im in info int io iq ir is it 
      je jm jo jobs jp 
      ke kg kh ki km kn kp kr kw ky kz 
      la lb lc li lk lr ls lt lu lv ly 
      ma mc md me mf mg mh mil mk ml mm mn mo mobi mp mq mr ms mt mu museum 
      mv mw mx my mz 
      na name nc ne net nf ng ni nl no np nr nu nz 
      om org 
      pa pe pf pg ph pk pl pm pn pr pro ps pt pw py 
      qa 
      re ro rs ru rw 
      sa sb sc sd se sg sh si sj sk sl sm sn so sr st su sv sy sz 
      tc td tel tf tg th tj tk tl tm tn to tp tr travel tt tv tw tz 
      ua ug uk um us uy uz 
      va vc ve vg vi vn vu 
      wf ws 
      ye yt yu 
      za zm zw
    )
    
    DEFAULT_ERROR_MSG = {
      :invalid_hostname_length            => 'hostname must be between 1 and 255 characters long',
      :invalid_label_length               => 'label must be between 1 and 63 characters long',
      :label_begins_or_ends_with_hyphen   => 'label begins or ends with hyphen',
      :label_contains_invalid_characters  => "label contains invalid characters (valid characters: [%{valid_chars}])",
      :hostname_label_is_numeric          => 'unqualified hostname part cannot consist of numeric values only',
      :hostname_is_not_fqdn               => 'hostname is not a fully qualified domain name',
      :single_numeric_hostname_label      => 'hostnames cannot consist of a single numeric label'
    }.freeze
    
    class HostnameValidator < ActiveModel::EachValidator
      def initialize(options)
        opts = {
          :allow_underscore        => false,
          :require_valid_tld       => false,
          :valid_tlds              => ALLOWED_TLDS,
          :allow_numeric_hostname  => false
        }.merge(options)
        super(opts)
      end
      
      def validate_each(record, attribute, value)
        # maximum hostname length: 255 characters
        add_error(record, attribute, :invalid_hostname_length) unless value.length.between?(1, 255)
        
        # split each hostname into labels and do various checks
        if value.is_a?(String)
          labels = value.split '.'
          labels.each do |label|
            # CHECK 1: hostname label cannot be longer than 63 characters
            add_error(record, attribute, :invalid_label_length) unless value.length.between?(1, 63)

            # CHECK 2: hostname label cannot begin or end with hyphen
            add_error(record, attribute, :label_begins_or_ends_with_hyphen) if label =~ /^[-]/i or label =~ /[-]$/

            # CHECK 3: hostname can only contain characters: 
            #          a-z, 0-9, hyphen, optionally underscore
            valid_chars = 'a-z0-9\-'
            valid_chars << '_' if options[:allow_underscore] == true
            add_error(record, attribute, :label_contains_invalid_characters, :valid_chars => valid_chars) unless label =~ /^[#{valid_chars}]+$/i
          end

          # CHECK 4: the unqualified hostname portion cannot consist of 
          #          numeric values only
          if options[:allow_numeric_hostname] == false
            is_numeric_only = (
              (
                Integer(labels[0]) rescue false
              ) ? true : false
            )
            add_error(record, attribute, :hostname_label_is_numeric) if is_numeric_only
          end

          # CHECK 5: in order to be fully qualified, the full hostname's
          #          TLD must be valid
          if options[:require_valid_tld] == true
            has_tld = options[:valid_tlds].select {
              |tld| tld =~ /^#{Regexp.escape(labels.last)}$/i
            }.empty? ? false : true
            add_error(record, attribute, :hostname_is_not_fqdn) unless has_tld
          end
        end
      end
      
      def add_error(record, attr_name, message, *interpolators)

        args = {
          :default => [DEFAULT_ERROR_MSG[message], options[:message]],
          :scope   => [:errors, :messages]
        }.merge(interpolators.last.is_a?(Hash) ? interpolators.pop : {})
        record.errors.add(attr_name, I18n.t( message, args ))
      end
    end

    class DomainnameValidator < HostnameValidator
      def initialize(options)
        opts = {
          :require_valid_tld       => true,
          :allow_numeric_hostname  => true
        }.merge(options)
        super(opts)
      end
      
      def validate_each(record, attribute, value)
        super
        
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
                record.errors.add(attribute, options[:message] || :single_numeric_hostname_label, :default => 'hostnames cannot consist of a single numeric label')
              end
            end
          end
        end
      end
    end

    class FqdnValidator < HostnameValidator
      def initialize(options)
        opts = {
          :require_valid_tld       => true,
        }.merge(options)
        super(opts)
      end
    end
  end
end

ActiveRecord::Base.send(:include, PAK::ValidatesHostname)