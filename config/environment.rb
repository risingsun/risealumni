
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


require File.join(RAILS_ROOT, 'config', 'application_variables')

Rails::Initializer.run do |config|

  #config.database_configuration_file = File.join(RAILS_ROOT, 'config', DATABASE_CONFIGURATION_FILE)
  require 'hodel_3000_compliant_logger'
  config.logger = Hodel3000CompliantLogger.new(config.log_path)

  # Cookie sessions (limit = 4K)
  config.action_controller.session = {
    :session_key => SESSION_KEY,
    :secret      => SECRET
  }
  #config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
  config.active_record.observers = :event_observer  

  config.load_paths << "#{RAILS_ROOT}/app/sweepers"

  # Gem dependencies
  config.gem 'youtube-g', :version=> '0.4.1', :lib=>'youtube_g'
  config.gem 'uuidtools', :version=> '1.0.3'
  config.gem 'ferret'
  config.gem 'avatar', :version=> '0.0.5'
  config.gem 'icalendar',:version => '1.0.2'
  config.gem 'will_paginate',:version =>'~> 2.2.2'
  config.gem 'ar_mailer',:version =>'1.3.1' ,:lib =>'action_mailer/ar_mailer' 
  config.gem 'mime-types',:version =>'1.15',:lib =>'mime/types'
  config.gem 'json'
  config.gem 'twitter4r',:lib => 'twitter'
  config.gem 'RedCloth', :version => '4.1.9', :lib => 'redcloth'
  config.gem 'fiveruns-memcache-client', :lib => 'memcache'
  config.active_record.colorize_logging = false
  config.gem 'facebooker'
  config.gem 'hpricot'
end

# The following line prevents Mongrels from dying after periods of inactivity
# Should be less than the interactive_timeout variable value on mysql
# mysql -u root -p and then show variables on the mysql prompt will tell you the
# variable's value; current it was 28800 so it is set to something below that
# number

