require 'active_support/concern'
require 'active_record'
require 'active_model'

module PAK
  module ValidatesHostname
    autoload :VERSION, 'validates_hostname/version'

    # List from IANA: http://www.iana.org/domains/root/db/
    #                 http://data.iana.org/TLD/tlds-alpha-by-domain.txt
    ALLOWED_TLDS = %w(
      . abogado ac academy accountants active actor ad adult ae aero af ag agency ai
      airforce al allfinanz alsace am amsterdam an android ao aq aquarelle ar archi
      army arpa as asia associates at attorney au auction audio autos aw ax axa az ba
      band bank bar bargains bayern bb bd be beer berlin best bf bg bh bi bid bike
      bio biz bj black blackfriday bloomberg blue bm bmw bn bnpparibas bo boo
      boutique br brussels bs bt budapest build builders business buzz bv bw by bz
      bzh ca cab cal camera camp cancerresearch capetown capital caravan cards care
      career careers cartier casa cash cat catering cc cd center ceo cern cf cg ch
      channel cheap christmas chrome church ci citic city ck cl claims cleaning click
      clinic clothing club cm cn co coach codes coffee college cologne com community
      company computer condos construction consulting contractors cooking cool coop
      country cr credit creditcard cricket crs cruises cu cuisinella cv cw cx cy
      cymru cz dad dance dating day de deals degree delivery democrat dental dentist
      desi dev diamonds diet digital direct directory discount dj dk dm dnp do docs
      domains doosan durban dvag dz eat ec edu education ee eg email emerck energy
      engineer engineering enterprises equipment er es esq estate et eu eurovision
      eus events everbank exchange expert exposed fail farm fashion feedback fi
      finance financial firmdale fish fishing fit fitness fj fk flights florist
      flowers flsmidth fly fm fo foo forsale foundation fr frl frogans fund furniture
      futbol ga gal gallery garden gb gbiz gd ge gent gf gg ggee gh gi gift gifts
      gives gl glass gle global globo gm gmail gmo gmx gn google gop gov gp gq gr
      graphics gratis green gripe gs gt gu guide guitars guru gw gy hamburg haus
      healthcare help here hiphop hiv hk hm hn holdings holiday homes horse host
      hosting house how hr ht hu ibm id ie il im immo immobilien in industries info
      ing ink institute insure int international investments io iq ir irish is it iwc
      je jetzt jm jo jobs joburg jp juegos kaufen kddi ke kg kh ki kim kitchen kiwi
      km kn koeln kp kr krd kred kw ky kz la lacaixa land lat latrobe lawyer lb lc
      lds lease legal lgbt li lidl life lighting limited limo link lk loans london
      lotto lr ls lt ltda lu luxe luxury lv ly ma madrid maison management mango
      market marketing mc md me media meet melbourne meme memorial menu mg mh miami
      mil mini mk ml mm mn mo mobi moda moe monash money mormon mortgage moscow
      motorcycles mov mp mq mr ms mt mu museum mv mw mx my mz na nagoya name navy nc
      ne net network neustar new nexus nf ng ngo nhk ni ninja nl no np nr nra nrw nu
      nyc nz okinawa om ong onl ooo org organic osaka otsuka ovh pa paris partners
      parts party pe pf pg ph pharmacy photo photography photos physio pics pictures
      pink pizza pk pl place plumbing pm pn pohl poker porn post pr praxi press pro
      prod productions prof properties property ps pt pub pw py qa qpon quebec re
      realtor recipes red rehab reise reisen reit ren rentals repair report
      republican rest restaurant reviews rich rio rip ro rocks rodeo rs rsvp ru ruhr
      rw ryukyu sa saarland sale samsung sarl sb sc sca scb schmidt schule schwarz
      science scot sd se services sew sexy sg sh shiksha shoes shriram si singles sj
      sk sky sl sm sn so social software sohu solar solutions soy space spiegel sr st
      su supplies supply support surf surgery suzuki sv sx sy sydney systems sz
      taipei tatar tattoo tax tc td technology tel tf tg th tienda tips tires tirol
      tj tk tl tm tn to today tokyo tools top town toys tp tr trade training travel
      trust tt tui tv tw tz ua ug uk university uno uol us uy uz va vacations vc ve
      vegas ventures versicherung vet vg vi viajes video villas vision vlaanderen vn
      vodka vote voting voto voyage vu wales wang watch webcam website wed wedding wf
      whoswho wien wiki williamhill wme work works world ws wtc wtf xn--1qqw23a
      xn--3bst00m xn--3ds443g xn--3e0b707e xn--45brj9c xn--45q11c xn--4gbrim
      xn--55qw42g xn--55qx5d xn--6frz82g xn--6qq986b3xl xn--80adxhks xn--80ao21a
      xn--80asehdb xn--80aswg xn--90a3ac xn--c1avg xn--cg4bki xn--clchc0ea0b2g2a9gcd
      xn--czr694b xn--czrs0t xn--czru2d xn--d1acj3b xn--d1alf xn--fiq228c5hs
      xn--fiq64b xn--fiqs8s xn--fiqz9s xn--flw351e xn--fpcrj9c3d xn--fzc2c9e2c
      xn--gecrj9c xn--h2brj9c xn--hxt814e xn--i1b6b1a6a2e xn--io0a7i xn--j1amh
      xn--j6w193g xn--kprw13d xn--kpry57d xn--kput3i xn--l1acc xn--lgbbat1ad8j
      xn--mgb9awbf xn--mgba3a4f16a xn--mgbaam7a8h xn--mgbab2bd xn--mgbayh7gpa
      xn--mgbbh1a71e xn--mgbc0a9azcg xn--mgberp4a5d4ar xn--mgbx4cd0ab xn--ngbc5azd
      xn--node xn--nqv7f xn--nqv7fs00ema xn--o3cw4h xn--ogbpf8fl xn--p1acf xn--p1ai
      xn--pgbs0dh xn--q9jyb4c xn--qcka1pmc xn--rhqv96g xn--s9brj9c xn--ses554g
      xn--unup4y xn--vermgensberater-ctb xn--vermgensberatung-pwb xn--vhquv
      xn--wgbh1c xn--wgbl6a xn--xhq521b xn--xkc2al3hye2a xn--xkc2dl3a5ee0h
      xn--yfro4i67o xn--ygbi2ammx xn--zfr164b xxx xyz yachts yandex ye yoga yokohama
      youtube yt za zip zm zone zuerich zw
    )

    DEFAULT_ERROR_MSG = {
      :invalid_hostname_length            => 'must be between 1 and 255 characters long',
      :invalid_label_length               => 'must be between 1 and 63 characters long',
      :label_begins_or_ends_with_hyphen   => 'begins or ends with hyphen',
      :label_contains_invalid_characters  => "contains invalid characters (valid characters: [%{valid_chars}])",
      :hostname_label_is_numeric          => 'unqualified hostname part cannot consist of numeric values only',
      :hostname_is_not_fqdn               => 'is not a fully qualified domain name',
      :single_numeric_hostname_label      => 'cannot consist of a single numeric label',
      :hostname_contains_consecutive_dots => 'must not contain consecutive dots',
      :hostname_ends_with_dot             => 'must not end with a dot'
    }.freeze

    class HostnameValidator < ActiveModel::EachValidator
      def initialize(options)
        opts = {
          :allow_underscore        => false,
          :require_valid_tld       => false,
          :valid_tlds              => ALLOWED_TLDS,
          :allow_numeric_hostname  => false,
          :allow_wildcard_hostname => false,
          :allow_root_label        => false
        }.merge(options)
        super(opts)
      end

      def validate_each(record, attribute, value)
        value ||= ''

        # maximum hostname length: 255 characters
        add_error(record, attribute, :invalid_hostname_length) unless value.length.between?(1, 255)

        # split each hostname into labels and do various checks
        if value.is_a?(String)
          labels = value.split '.'
          labels.each_with_index do |label, index|
            # CHECK 1: hostname label cannot be longer than 63 characters
            add_error(record, attribute, :invalid_label_length) unless value.length.between?(1, 63)

            # CHECK 2: hostname label cannot begin or end with hyphen
            add_error(record, attribute, :label_begins_or_ends_with_hyphen) if label =~ /^[-]/i or label =~ /[-]$/

            # Take care of wildcard first label
            next if options[:allow_wildcard_hostname] and label == '*' and index == 0

            # CHECK 3: hostname can only contain characters: 
            #          a-z, 0-9, hyphen, optional underscore, optional asterisk
            valid_chars = 'a-z0-9\-'
            valid_chars << '_' if options[:allow_underscore] == true
            add_error(record, attribute, :label_contains_invalid_characters, :valid_chars => valid_chars) unless label =~ /^[#{valid_chars}]+$/i
          end

          # CHECK 4: the unqualified hostname portion cannot consist of 
          #          numeric values only
          if options[:allow_numeric_hostname] == false and labels.length > 0
            is_numeric_only = labels[0] =~ /\A\d+\z/
            add_error(record, attribute, :hostname_label_is_numeric) if is_numeric_only
          end

          # CHECK 5: in order to be fully qualified, the full hostname's
          #          TLD must be valid
          if options[:require_valid_tld] == true
            my_tld = value == '.' ? value : labels.last
            my_tld ||= ''
            has_tld = options[:valid_tlds].select {
              |tld| tld =~ /^#{Regexp.escape(my_tld)}$/i
            }.empty? ? false : true
            add_error(record, attribute, :hostname_is_not_fqdn) unless has_tld
          end

          # CHECK 6: hostname may not contain consecutive dots
          if value =~ /\.\./
            add_error(record, attribute, :hostname_contains_consecutive_dots)
          end

          # CHECK 7: do not allow trailing dot unless option is set
          if options[:allow_root_label] == false
            if value =~ /\.$/
              add_error(record, attribute, :hostname_ends_with_dot)
            end
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
              is_numeric_only = labels[0] =~ /\A\d+\z/
              if is_numeric_only and labels.size == 1
                add_error(record, attribute, :single_numeric_hostname_label)
              end
            end
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

    class FqdnValidator < HostnameValidator
      def initialize(options)
        opts = {
          :require_valid_tld       => true,
        }.merge(options)
        super(opts)
      end
    end

    class WildcardValidator < HostnameValidator
      def initialize(options)
        opts = {
          :allow_wildcard_hostname => true,
        }.merge(options)
        super(opts)
      end
    end
  end
end

ActiveRecord::Base.send(:include, PAK::ValidatesHostname)
