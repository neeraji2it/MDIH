# This initializer is setting all the global variable of the My Date IS Here.



SITE_LANGUAGES = ["en-US", "it"]
SITE_NAME = "My Date Is Here"
GENDERS = ["Male", "Female", "Transman", "Transwoman"]
LOOKING_FOR = ["All", "Female", "Male", "Bisexual", "Transwoman", "Transman"]
INTERESTED_IN = ["marriage", "dating", "casual", "relationship", "friend", "friends w/benefits"]
HOME_INTERESTED_IN = ["marriage", "dating", "casual", "relationship", "friend"]
ORIENTATION = ['Straight', 'Gay', 'Lesbian', 'Bisexual']
ORDER = [["Newest", "Newest"], ["Closest","Closest"], ["Last on line", "Lastonline"]]
PROFILE_LANGUAGES = ["English"] + ["Farsi/Persian", "Albanian", "Arabic", "Aramaic", "Armenian", "Chinese", "Dutch", "French", "German", "Greek", "Hebrew", "Hindi", "Italian", "Japanese", "Korean", "Ukrainian","Portuguese", "Punjabi", "Romanian", "Russian", "Urdu","Sindhi", "Spanish", "Tagalog", "Turkish", "Vietnamese"].sort + ["Other"]
# Variable to define number of emails to send per hour
EMAILS_PER_HOUR = 20
ADMIN_EMAIL = 'admin@mydateishere.com'
FEEDBACK_EMAIL = 'feedback@mydateishere.com'

OPEN_TOK_API_KEY = "12628261"
OPEN_TOK_API_SECRET = "56ad0a53206e9e80aec90d428c35321696690fa9"

#CREDITS_RATE = [[10, 5], [100, 10], [1000, 50]]
CREDITS_RATE = [[20, 9.99], [50, 19.99], [80, 29.99], [120, 39.99], [200, 49.99]]
SIGNUP_CREDITS = 100
BIRTH_DAY_CREDITS = 50
ANNIVERSARY_CREDITS = 50
INVITATION_CREDITS = 50

####FACEBOOK_API_KEY = "18f5749b9832fc13fea18817a81ae65e"

# uncomment for localhost
BASE_URL = "http://localhost:3000"
FACEBOOK_CONNECT_API = "365492663501151"
FACEBOOK_SECRET_KEY = "6c1d03aa136b9cce94a082293ec923a3"
S3_BUCKET_NAME = "mdih_staging"

#uncomment for staging2.myroya.com development
#BASE_URL = "http://staging2.myroya.com"
#FACEBOOK_CONNECT_API = "365492663501151"
#FACEBOOK_SECRET_KEY = "6c1d03aa136b9cce94a082293ec923a3"
#S3_BUCKET_NAME = "mdih_staging"


#BASE_URL = "http://staging.myroya.com"
#FACEBOOK_CONNECT_API = "d63f6eb933b04ab58619efa8d69bb924"
#FACEBOOK_SECRET_KEY = "cef3c6c48f7917448e307d4979379a41"
#S3_BUCKET_NAME = "mdih_staging"

#uncomment for mydateishere.com development
#BASE_URL = "http://www.mydateishere.com"
#FACEBOOK_CONNECT_API = "7f19737606e77be26699fce7c382a9ea"
#FACEBOOK_SECRET_KEY = "8cb9e0d2284469c3b35e615033a33639"
#S3_BUCKET_NAME = "mdih_production"

#old fb settings for production
#FACEBOOK_CONNECT_API = "97ba7744f6cc8a9a722a9ab8428cdfb0"
#FACEBOOK_SECRET_KEY = "ccfc8bc89a032aaa10a84341329827af"


#ExceptionNotifier.exception_recipients = %w(mdih@dine-media.com sedighi@sedighi.com edwardvalentini@gmail.com)
#ExceptionNotifier.sender_address = 'error@mydateishere.com'
#ExceptionNotifier.email_prefix = "My Date Is Here "

# add - as an okay key
class CGI
  class Session
    class MemCacheStore
      def check_id(id) #:nodoc:#
        /[^0-9a-zA-Z\-\._]+/ =~ id.to_s ? false : true
      end
    end
  end
end
