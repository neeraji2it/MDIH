# encoding: utf-8
class PayPal < ActiveRecord::Base
  def self.columns
    @columns ||= [];
  end

  attr_accessor :card_number, :card_verification, :first_name, :last_name, :card_type, :card_expires_on, :price, :ip_address, :user_id, :address, :city, :state, :zip, :country

  #  validate_on_create :validate_card

  def purchase
    response = GATEWAY.purchase(price_in_cents, credit_card, purchase_options)
    Payment.create!(:user_id => self.user_id, :first_name => self.first_name, :ip_address => self.ip_address, :last_name => self.last_name, :action => "Gift purchased", :amount => price_in_cents, :response => response, :address => self.address, :city => self.city, :state => self.state, :zip => self.zip, :country => self.country)
    #    cart.update_attribute(:purchased_at, Time.now) if response.success?
    response.success?
  end

  def price_in_cents
    (self.price*100).round
  end

  #  private

  def purchase_options
    {
      :ip => self.ip_address,
      :billing_address => {
        :name     => self.first_name+" "+self.last_name,
        :address1 => self.address,
        :city     => self.city,
        :state    => self.state,
        :country  => self.country,
        :zip      => self.zip,
      }
    }
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors[:base] << message
        return false
      end
    end
    return true
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => self.card_type,
      :number             => self.card_number,
      :verification_value => self.card_verification,
      :month              => self.card_expires_on.month,
      :year               => self.card_expires_on.year,
      :first_name         => self.first_name,
      :last_name          => self.last_name
    )
  end

  def self.credits_to_money(credits)
    money = 0.0
    credits = credits || 0
    CREDITS_RATE.reverse.each do |c, r|
      if credits >= c
        m = credits/c
        credits = (credits - (c*m))
        money = money+(m*r)
      end
    end
    if credits > 0 and CREDITS_RATE[0]
      money = money + (credits*(CREDITS_RATE[0][1].to_f/CREDITS_RATE[0][0].to_f))
    end
    return money.round(2)
  end

  def self.countries
    countries = {
      :af => "Afghanistan",
      :ax => "Aland islands",
      :al => "Albania",
      :dz => "Algeria",
      :as => "American samoa",
      :ad => "Andorra",
      :ao => "Angola",
      :ai => "Anguilla",
      :aq => "Antarctica",
      :ag => "Antigua and barbuda",
      :ar => "Argentina",
      :am => "Armenia",
      :aw => "Aruba",
      :au => "Australia",
      :at => "Austria",
      :az => "Azerbaijan",
      :bs => "Bahamas",
      :bh => "Bahrain",
      :bd => "Bangladesh",
      :bb => "Barbados",
      :by => "Belarus",
      :be => "Belgium",
      :bz => "Belize",
      :bj => "Benin",
      :bm => "Bermuda",
      :bt => "Bhutan",
      :bo => "Bolivia",
      :ba => "Bosnia and herzegovina",
      :bw => "Botswana",
      :bv => "Bouvet island",
      :br => "Brazil",
      :io => "British indian ocean territory",
      :bn => "Brunei darussalam",
      :bg => "Bulgaria",
      :bf => "Burkina faso",
      :bi => "Burundi",
      :kh => "Cambodia",
      :cm => "Cameroon",
      :ca => "Canada",
      :cv => "Cape verde",
      :ky => "Cayman islands",
      :cf => "Central african republic",
      :td => "Chad",
      :cl => "Chile",
      :cn => "China",
      :cx => "Christmas island",
      :cc => "Cocos (keeling islands",
      :co => "Colombia",
      :km => "Comoros",
      :cg => "Congo",
      :cd => "Congo, the democratic republic of the",
      :ck => "Cook islands",
      :cr => "Costa rica",
      :ci => "Côte d'ivoire",
      :hr => "Croatia",
      :cu => "Cuba",
      :cy => "Cyprus",
      :cz => "Czech republic",
      :dk => "Denmark",
      :dj => "Djibouti",
      :dm => "Dominica",
      :do => "Dominican republic",
      :ec => "Ecuador",
      :eg => "Egypt",
      :sv => "El salvador",
      :gq => "Equatorial guinea",
      :er => "Eritrea",
      :ee => "Estonia",
      :et => "Ethiopia",
      :fk => "Falkland islands (malvinas",
      :fo => "Faroe islands",
      :fj => "Fiji",
      :fi => "Finland",
      :fr => "France",
      :gf => "French guiana",
      :pf => "French polynesia",
      :tf => "French southern territories",
      :ga => "Gabon",
      :gm => "Gambia",
      :ge => "Georgia",
      :de => "Germany",
      :gh => "Ghana",
      :gi => "Gibraltar",
      :gr => "Greece",
      :gl => "Greenland",
      :gd => "Grenada",
      :gp => "Guadeloupe",
      :gu => "Guam",
      :gt => "Guatemala",
      :gg => "Guernsey",
      :gn => "Guinea",
      :gw => "Guinea-bissau",
      :gy => "Guyana",
      :ht => "Haiti",
      :hm => "Heard island and mcdonald islands",
      :va => "Holy see (vatican city state",
      :hn => "Honduras",
      :hk => "Hong kong",
      :hu => "Hungary",
      :is => "Iceland",
      :in => "India",
      :id => "Indonesia",
      :ir => "Iran, islamic republic of",
      :iq => "Iraq",
      :ie => "Ireland",
      :im => "Isle of man",
      :il => "Israel",
      :it => "Italy",
      :jm => "Jamaica",
      :jp => "Japan",
      :je => "Jersey",
      :jo => "Jordan",
      :kz => "Kazakhstan",
      :ke => "Kenya",
      :ki => "Kiribati",
      :kp => "Korea, democratic people's republic of",
      :kr => "Korea, republic of",
      :kw => "Kuwait",
      :kg => "Kyrgyzstan",
      :la => "Lao people's democratic republic",
      :lv => "Latvia",
      :lb => "Lebanon",
      :ls => "Lesotho",
      :lr => "Liberia",
      :ly => "Libyan arab jamahiriya",
      :li => "Liechtenstein",
      :lt => "Lithuania",
      :lu => "Luxembourg",
      :mo => "Macao",
      :mk => "Macedonia, the former yugoslav republic of",
      :mg => "Madagascar",
      :mw => "Malawi",
      :my => "Malaysia",
      :mv => "Maldives",
      :ml => "Mali",
      :mt => "Malta",
      :mh => "Marshall islands",
      :mq => "Martinique",
      :mr => "Mauritania",
      :mu => "Mauritius",
      :yt => "Mayotte",
      :mx => "Mexico",
      :fm => "Micronesia, federated states of",
      :md => "Moldova, republic of",
      :mc => "Monaco",
      :mn => "Mongolia",
      :me => "Montenegro",
      :ms => "Montserrat",
      :ma => "Morocco",
      :mz => "Mozambique",
      :mm => "Myanmar",
      :na => "Namibia",
      :nr => "Nauru",
      :np => "Nepal",
      :nl => "Netherlands",
      :an => "Netherlands antilles",
      :nc => "New caledonia",
      :nz => "New zealand",
      :ni => "Nicaragua",
      :ne => "Niger",
      :ng => "Nigeria",
      :nu => "Niue",
      :nf => "Norfolk island",
      :mp => "Northern mariana islands",
      :no => "Norway",
      :om => "Oman",
      :pk => "Pakistan",
      :pw => "Palau",
      :ps => "Palestinian territory, occupied",
      :pa => "Panama",
      :pg => "Papua new guinea",
      :py => "Paraguay",
      :pe => "Peru",
      :ph => "Philippines",
      :pn => "Pitcairn",
      :pl => "Poland",
      :pt => "Portugal",
      :pr => "Puerto rico",
      :qa => "Qatar",
      :re => "Reunion",
      :ro => "Romania",
      :ru => "Russian federation",
      :rw => "Rwanda",
      :bl => "Saint barthélemy",
      :sh => "Saint helena",
      :kn => "Saint kitts and nevis",
      :lc => "Saint lucia",
      :mf => "Saint martin",
      :pm => "Saint pierre and miquelon",
      :vc => "Saint vincent and the grenadines",
      :ws => "Samoa",
      :sm => "San marino",
      :st => "Sao tome and principe",
      :sa => "Saudi arabia",
      :sn => "Senegal",
      :rs => "Serbia",
      :sc => "Seychelles",
      :sl => "Sierra leone",
      :sg => "Singapore",
      :sk => "Slovakia",
      :si => "Slovenia",
      :sb => "Solomon islands",
      :so => "Somalia",
      :za => "South africa",
      :gs => "South georgia and the south sandwich islands",
      :es => "Spain",
      :lk => "Sri lanka",
      :sd => "Sudan",
      :sr => "Suriname",
      :sj => "Svalbard and jan mayen",
      :sz => "Swaziland",
      :se => "Sweden",
      :ch => "Switzerland",
      :sy => "Syrian arab republic",
      :tw => "Taiwan, province of china",
      :tj => "Tajikistan",
      :tz => "Tanzania, united republic of",
      :th => "Thailand",
      :tl => "Timor-leste",
      :tg => "Togo",
      :tk => "Tokelau",
      :to => "Tonga",
      :tt => "Trinidad and tobago",
      :tn => "Tunisia",
      :tr => "Turkey",
      :tm => "Turkmenistan",
      :tc => "Turks and caicos islands",
      :tv => "Tuvalu",
      :ug => "Uganda",
      :ua => "Ukraine",
      :ae => "United arab emirates",
      :gb => "United kingdom",
      :us => "United states",
      :um => "United states minor outlying islands",
      :uy => "Uruguay",
      :uz => "Uzbekistan",
      :vu => "Vanuatu",
      :ve => "Venezuela",
      :vn => "Viet nam",
      :vg => "Virgin islands, british",
      :vi => "Virgin islands, u.s.",
      :wf => "Wallis and futuna",
      :eh => "Western sahara",
      :ye => "Yemen",
      :zm => "Zambia",
      :zw => "Zimbabwe"
    }
    cc = []
    countries.each do |key, value|
      cc << [value, key.to_s]
    end
    return cc
  end
end
