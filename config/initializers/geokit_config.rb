if defined? Geokit

	# These defaults are used in Geokit::Mappable.distance_to and in acts_as_mappable
	Geokit::default_units = :miles
	Geokit::default_formula = :sphere

	# This is the timeout value in seconds to be used for calls to the geocoder web
	# services.  For no timeout at all, comment out the setting.  The timeout unit
	# is in seconds. 
	Geokit::Geocoders::request_timeout = 3

	# These settings are used if web service calls must be routed through a proxy.
	# These setting can be nil if not needed, otherwise, addr and port must be 
	# filled in at a minimum.  If the proxy requires authentication, the username
	# and password can be provided as well.
	Geokit::Geocoders::proxy_addr = nil
	Geokit::Geocoders::proxy_port = nil
	Geokit::Geocoders::proxy_user = nil
	Geokit::Geocoders::proxy_pass = nil

	# This is your yahoo application key for the Yahoo Geocoder.
	# See http://developer.yahoo.com/faq/index.html#appid
	# and http://developer.yahoo.com/maps/rest/V1/geocode.html
#	Geokit::Geocoders::yahoo = 'xxmqpvbV34EQXjNsKKtZfbI9dhAbyjbkJ78PcmPFLMyyeGz2J2j9DT1jfJXsAV9WqiNw'
  Geokit::Geocoders::yahoo = 'mV9KcnrV34E_FWJHpOr4VScqMwsRmcX0Y4SNe5n1Qnvm6y5FOy8FwS8lR_AytQVS'
    
	# This is your Google Maps geocoder key. 
	# See http://www.google.com/apis/maps/signup.html
	# and http://www.google.com/apis/maps/documentation/#Geocoding_Examples
#	Geokit::Geocoders::google = 'ABQIAAAAqfoDq8EgNHdBz8QIdlIeKxSkX9o7Oml-qyLE0IpgZ1dQfjq4KRSfSDmSX-r4Tc8Bzb0k2V7cNljexg'
  Geokit::Geocoders::google = 'ABQIAAAAPfkE6lmWzrGYkUgsdsR94RTNazbfXhotynoqsM3rsGl1ExSpLhRXoQzXxHcOABME3lD7LBSGQPgP6w'
    
	# This is your username and password for geocoder.us.
	# To use the free service, the value can be set to nil or false.  For 
	# usage tied to an account, the value should be set to username:password.
	# See http://geocoder.us
	# and http://geocoder.us/user/signup
#	Geokit::Geocoders::geocoder_us = 'rnagarjuna:MkYjjqAn'
  Geokit::Geocoders::geocoder_us = 'mdih:qNk0rBoI'

	# This is your authorization key for geocoder.ca.
	# To use the free service, the value can be set to nil or false.  For 
	# usage tied to an account, set the value to the key obtained from
	# Geocoder.ca.
	# See http://geocoder.ca
	# and http://geocoder.ca/?register=1
#	Geokit::Geocoders::geocoder_ca = false
  Geokit::Geocoders::geocoder_ca = '514591984564528483543x1614'

	# Uncomment to use a username with the Geonames geocoder
	#Geokit::Geocoders::geonames="REPLACE_WITH_YOUR_GEONAMES_USERNAME"

	# This is the order in which the geocoders are called in a failover scenario
	# If you only want to use a single geocoder, put a single symbol in the array.
	# Valid symbols are :google, :yahoo, :us, and :ca.
	# Be aware that there are Terms of Use restrictions on how you can use the 
	# various geocoders.  Make sure you read up on relevant Terms of Use for each
	# geocoder you are going to use.
	Geokit::Geocoders::provider_order = [:google,:yahoo, :us, :ca]

	# The IP provider order. Valid symbols are :ip,:geo_plugin.
	# As before, make sure you read up on relevant Terms of Use for each
	 Geokit::Geocoders::ip_provider_order = [:geo_plugin,:ip]

end
