# Change globals to match the proper value for your site
DELETE_CONFIRM = "Are you sure you want to delete?\nThis can not be undone."
SEARCH_LIMIT = 25

# Site specific
SITE_NAME_FULL = 'Rise Alumni Application'
SITE_NAME = 'RiseAlumni'
SITE_DESC = 'Wish for more'
SITE = RAILS_ENV == 'production' ? 'risealumni.com' : 'localhost:10000'
ActionMailer::Base.default_url_options[:host] = SITE
SITE_NOT_RECORD_MSG = "Not Found"

# Flick related
FLICKR_USER_ACCOUNT = 'risealumni' unless RAILS_ENV == 'development'
FLICKR_IMAGES = 500
FLICKR_IMGAES_ON_SIDE_BAR = 6
FLICKR_IMGAES_ON_PROFILE = 10
FLICKR_IMAGES_PER_PAGE = 10

#Twitter
TWITTER_ENABLED = true && File.exists?("#{RAILS_ROOT}/config/twitter.yml")
if TWITTER_ENABLED
  yaml_hash = YAML.load(File.read("#{RAILS_ROOT}/config/twitter.yml"))
  TWITTER_LOGIN = yaml_hash['user']['login']
  TWITTER_FOLLOW_URL = "http://twitter.com/#{TWITTER_LOGIN}"
end

# YouTube related
YOUTUBE_BASE_URL = "http://gdata.youtube.com/feeds/api/videos/"

# Email related
MAILER_TO_ADDRESS = "info@#{SITE}"
MAILER_FROM_ADDRESS_SIMPLE = "no-reply@#{SITE}"
MAILER_FROM_ADDRESS = 'Rise Alumni Team <no-reply@risealumni.com>'

ADMIN_RECIPIENTS = %W("your admin ids") #send an email to this list everytime someone signs up
BATCH_RANGE = 1949..(Date.today.year + 1)

# Expiry times
SITE_FLICKR_EXPIRE_TIME_MIN = 60
EXPIRE_TIME_IN_MIN = 20

#Key Search Values
SEARCH_KEYS = ['name','location','blood_group','year','blog','phone','address']

#House Names
HOUSE_NAMES = [['Blue'],['Red'],['Yellow'],['Green']]

#Groups
USER_TYPE = [['Admin'], ['Teacher'], ['Guest']]
GROUPS = BATCH_RANGE.inject(USER_TYPE){ |s, a| s << [a.to_s]}

#Titles
TITLES = [['Mr.'],['Mrs.'],['Ms.'],['Dr.'],['Er.'],['Lt.'],['Capt.'],['Col.'],['Maj.'],['Prof.'],['Advct.']]

# Control the number of items on different pages
RESULT_PER_PAGE = 16
NEWEST_MEMBER = 6
FEEDS_DISPLAY = 20
PROFILE_PER_PAGE = 16
BLOGS_ON_PROFILE = 10
BLOGS_PER_PAGE = 15
BLOGS_ON_HOME_PAGE = 6
POLLS_ON_PROFILE = 10
POLLS_PER_PAGE = 10
GOOGLE_MAP_DEFAULT_LAT = 26.89765464254534
GOOGLE_MAP_DEFAULT_LON = 75.81145763397217
GOOGLE_MAP_DEFAULT_ZOOM = 14

GOOGLE_ANALYTICS_TRACKER = "UA-2253707-6"
GOOGLE_CHART_COLOUR_ARRAY = %w(3CD983 C4D925 BABF1B BFA20F A66D03 732C02)

if RAILS_ENV == "production"
  ENV['INLINEDIR'] = RAILS_ROOT + "/tmp"
end
DISABLE_STUDENT_CHECKING = true
AD_ARRAY = [{:link => "/feedback", :image => 'banner.gif', :alt => 'To Place Your Ad Contact Us'},
            {:link => "http://www.risingsuntech.net", :image => '5.png', :alt => 'Rising Sun'}]


ActionMailer::Base.smtp_settings = {
  :address => "Your Address",
  :port => 25,
  :domain => "your Domain name",
  :authentication => :plain,
  :user_name => "Your user name",
  :password => "Your password"
}


require 'flickr'

FLICKR_KEY = 'Your flickr key'
FLICKR_SECRET = 'Your flickr secret'
FLICKR_CACHE = "#{RAILS_ROOT}/config/flickr.cache"
# Overwrite default url and path
Paperclip::Attachment.default_options[:path] = ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
Paperclip::Attachment.default_options[:url] = "/system/:class/:attachment/:id/:style/:basename.:extension"
#FB connect feed stories bundle ids
BE_FRIEND_BUNDLE_ID = 'Your be friend bundle id'
FOLLOW_BUNDLE_ID = 'Your follow friend story bundle id'
PROFILE_COMMENT_BUNDLE_ID = 'Your profile comment story bundle id'
BLOG_COMMENT_BUNDLE_ID = 'Your blog comment story bundle id'
BLOG_BUNDLE_ID = 'Your blog story bundle id'