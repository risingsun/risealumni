# == Schema Information
# Schema version: 2
#
# Table name: profiles
#
#  id                         :integer(11)   not null, primary key
#  user_id                    :integer(11)   
#  first_name                 :string(255)   
#  last_name                  :string(255)   
#  website                    :string(255)   
#  blog                       :string(255)   
#  flickr                     :string(255)   
#  about_me                   :text          
#  aim_name                   :string(255)   
#  gtalk_name                 :string(255)   
#  ichat_name                 :string(255)   
#  icon                       :string(255)   
#  location                   :string(255)   
#  created_at                 :datetime      
#  updated_at                 :datetime      
#  email                      :string(255)   
#  is_active                  :boolean(1)    
#  youtube_username           :string(255)   
#  flickr_username            :string(255)   
#  year                       :string(255)   
#  date_of_birth              :date          
#  anniversary_date           :date          
#  relationship_status        :string(255)   
#  spouse_name                :string(255)   
#  maiden_name                :string(255)   
#  gender                     :string(255)   
#  activities                 :text          
#  yahoo_name                 :string(255)   
#  skype_name                 :string(255)   
#  status_message             :string(255)   
#  occupation                 :string(255)   
#  industry                   :string(255)   
#  company_name               :string(255)   
#  company_website            :string(255)   
#  job_description            :text          
#  address_line1              :string(255)   
#  address_line2              :string(255)   
#  postal_code                :string(255)   
#  city                       :string(255)   
#  state                      :string(255)   
#  country                    :string(255)   
#  landline                   :string(255)   
#  mobile                     :string(255)   
#  professional_qualification :string(255)   
#  default_permission         :string(255)   default("Everyone")
#  middle_name                :string(255)   
#  linkedin_name              :string(255)   
#  msn_username               :string(255)   
#  twitter_username           :string(255)   
#

class Profile < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  FEEDS_DISPLAY = 20
  RELATIONSHIP_STATUS = [['Married'],['Single'],['Not Sure!']]
  PRIVACY_OPTIONS = [['Myself'],['Friends'],['Everyone']]
  PERMISSION_FIELDS = %w(website blog about_me gtalk_name location email
                         date_of_birth anniversary_date relationship_status
                         spouse_name gender activities yahoo_name skype_name
                         educations work_informations delicious_name
                         twitter_username msn_username linkedin_name 
                         address landline mobile marker)
  GENDER_FIELDS = [['Male'], ['Female']]
  BLOOD_GROUPS = [['A+'],['A-'],['B+'],['B-'],['AB+'],['AB-'],['O+'],['O-']]
  Profile::NOWHERE = 'Nowhere'
  DEFAULT_STATUS_MESSAGE = "Set your status!!"

  belongs_to :user

=begin
  TODO move is_Active to user
  rename it to active
=end
  attr_protected :is_active
  validates_format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message=>'does not look like an email address.'
  validates_presence_of :first_name, :last_name, :gender,:group
  validates_presence_of :email
  validates_uniqueness_of :email
 
  #invitaions
  has_many :invitations
  
  # Feeds
  has_many :feeds
  has_many :feed_items, :through => :feeds, :order => 'updated_at desc', :limit => FEEDS_DISPLAY
  has_many :private_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => false}, :order => 'created_at desc'
  has_many :public_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => true}, :order => 'created_at desc'

  # Messages
  has_many :sent_messages,     :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id', :conditions => "sender_flag = #{true} and system_message = #{false}"
  has_many :received_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'receiver_id', :conditions => "receiver_flag = #{true}"
  has_many :unread_messages,   :class_name => 'Message', :conditions => ["messages.read = #{false}"], :foreign_key => 'receiver_id'

  # Friends
  has_many :friendships, :class_name  => "Friend", :foreign_key => 'inviter_id', :conditions => "status = #{Friend::ACCEPTED}"
  has_many :follower_friends, :class_name => "Friend", :foreign_key => "invited_id", :conditions => "status = #{Friend::PENDING}"
  has_many :following_friends, :class_name => "Friend", :foreign_key => "inviter_id", :conditions => "status = #{Friend::PENDING}"

  has_many :friends,   :through => :friendships, :source => :invited, :conditions => "is_active = true"
  has_many :followers, :through => :follower_friends, :source => :inviter, :conditions => "is_active = true"
  has_many :followings, :through => :following_friends, :source => :invited, :conditions => "is_active = true"

  # Comments and Blogs
  has_many :comments, :as => :commentable, :order => 'created_at desc'
  has_many :unsent_blogs, :class_name => "Blog", :foreign_key => "profile_id", :conditions => 'is_sent = false'
  has_many :blogs, :order => 'created_at desc'

  # Education
  has_many :educations, :dependent => :destroy, :attributes => true
  has_many :work_informations, :dependent => :destroy, :attributes => true
  has_many :permissions, :dependent => :destroy, :attributes => true
  has_many :feedbacks
  #validates_associated :educations
  
  has_many :polls, :dependent => :destroy
  has_many :poll_responses, :dependent => :destroy
  has_one :notification_control, :dependent => :destroy
  has_one :student_check
  belongs_to :marker, :dependent => :destroy
  has_many :forum_posts, :foreign_key => 'owner_id', :dependent => :destroy
  has_many :profile_events,:dependent => :destroy
  has_many :events, :through => :profile_events
  has_many :organizing,:through => :profile_events,:source => :event,:conditions => "profile_events.role = 'Organizer'"
  has_many :events_attending,:through => :profile_events,:source => :event,:conditions => "profile_events.role = 'Attending'"
  has_many :events_not_attending,:through => :profile_events,:source => :event, :conditions => "profile_events.role = 'Not Attending'"
  has_many :events_may_be_attending,:through => :profile_events,:source => :event,:conditions => "profile_events.role = 'May Be Attending'"
  
  acts_as_ferret :fields => [ :location, :full_name, :group, :blood_group, :extra_details, :education_details,
    :address_details, :work_details, :status_check], :remote => true

  attr_accessor :profile_name  # taken a hidden field for attribute fu
  attr_accessor :login
  attr_reader :status_message
 
  named_scope :recent, lambda{|within| {:conditions => ["date_format(created_at,'%d%m%y') = ?",within.strftime("%d%m%y")]}}
  named_scope :active, :conditions => {:is_active => true}
  named_scope :user_not_null, :conditions => ["user_id is not null"]
  named_scope :group, lambda{|y| {:conditions => ["profiles.group = ?",y]}}
  named_scope :with_email_verified, :conditions => ["users.email_verified = 1"] , :include => :user
  named_scope :birthdays_on, lambda{|d|{:conditions => ["date_format(date_of_birth,'%d%m') = ?",d.strftime("%d%m")]}}
  named_scope :name_ordered, :order => 'profiles.group, first_name, last_name'
  named_scope :new_joined, :order => 'created_at desc'
  named_scope :fresh, lambda {|limit| {:order => 'created_at desc', :limit => limit || NEWEST_MEMBER}}
 
  def self.latest_in_batch(group)
    group(group).active.new_joined.first
  end
  
  def status_message
    if read_attribute(:status_message).blank?
      DEFAULT_STATUS_MESSAGE
    else
      read_attribute(:status_message)
    end
  end
 

  def default_status?
    status_message == DEFAULT_STATUS_MESSAGE
  end
  
  def default_location?
    location == Profile::NOWHERE
  end
 
  has_attached_file :icon,
    :styles =>
    {:big => "150x150#",
    :medium => "100x100#",
    :small =>"50x50#",
    :small_60 =>  "60x60#",
    :small_20 =>  "20x20#"
  }
  validates_attachment_content_type :icon, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  cattr_accessor :featured_profile
  @@featured_profile = {:date=>Date.today-4, :profile=>nil}
  @@days = ()

  #  def valid_email?(mail_field)
  #    begin
  #      write_attribute(mail_field,TMail::Address.parse(read_attribute(mail_field)).spec)
  #    rescue
  #      errors.add_to_base("Must be a valid email")
  #    end
  #  end

  def self.todays_featured_profile
    unless featured_profile[:date] == Date.today
      featured_profile[:profile] = featured
      featured_profile[:date] = Date.today
    end
    featured_profile[:profile]
  end

  def self.featured
    unless @featured
      ids = connection.select_all("select id from profiles where is_active = true and about_me != ''")
      @featured = find(ids[rand(ids.length)]["id"].to_i) unless ids.blank?
    end
    @featured
  end
    
  def date_of_birth_before_type_cast
    dob = read_attribute(:date_of_birth)
    dob.to_date.to_formatted_s(:rfc822) unless dob.nil?
  end
  
  def anniversary_date_before_type_cast
    ad = read_attribute(:anniversary_date)
    ad.to_date.to_formatted_s(:rfc822) unless ad.nil?
  end
  
  def date_of_birth_formatted
    date_of_birth.to_date.to_formatted_s(:rfc822) unless date_of_birth.blank?
  end
  
  def anniversary_date_formatted
    anniversary_date.to_date.to_formatted_s(:rfc822) unless anniversary_date.blank?
  end

  def self.new_members(limit = NEWEST_MEMBER)
    active.user_not_null.fresh(limit) # show the newest member if the user is active only
  end

  def maiden_name
    self[:maiden_name].titlecase unless self[:maiden_name].blank?
  end

  def spouse_name
    self[:spouse_name].titlecase unless self[:spouse_name].blank?
  end

  def status_check
    is_active? ? 'active activated' : 'deactive deactivated'
  end

  def status
    is_active? ? 'activated' : 'deactivated'
  end

  def to_param
    "#{self.id}-#{full_name.to_safe_uri}"
  end

  def has_network?
    !(self.followers + self.friends + self.followings).blank?
    #!Friend.find(:first, :conditions => ["invited_id = ? or inviter_id = ?", id, id]).blank?
  end

  def f(tr=15, options={})
    truncate(full_name(options),:length => tr)
  end
  
  def full_name(options={})
    n = [(title if options[:is_long]),first_name,(middle_name unless options[:is_short]),last_name].reject(&:blank?).compact.join(' ').titleize
    if n.blank?
      n = user.login rescue 'Deleted user'
    end
    n
  end

  def education_details
    unless self.educations.blank?
      education_detail_arr = []
      self.educations.each do |education|
        education_detail_arr << education.highschool_name
        education_detail_arr << education.university
      end
      return education_detail_arr
    end
  end
  
  def extra_details
    [self.email, self.about_me, self.date_of_birth , self.anniversary_date, 
      self.relationship_status, self.spouse_name, self.maiden_name, 
      self.activities, self.house_name,self.professional_qualification].compact.join(' ')
  end

  def address
    [address_line1, address_line2, 
      city, postal_code, state, country].reject(&:blank?).map(&:titlecase).join("<br/>")
  end

  def address_details
    [self.address_line1, self.address_line2, self.postal_code,
      self.city, self.state, self.country,
      self.landline, self.mobile].compact.join(' ')
  end
  

  [:news_email, :news_message, :event_email, :event_message, :message_email, :message_message, :blog_comment_email,
    :blog_comment_message, :profile_comment_email, :profile_comment_message, :follow_email, :follow_message,
    :delete_friend_email, :delete_friend_message].each do |notice| 
    ws_notify = <<-EOF
      def wants_#{notice.to_s}_notification?
        !notification_control.blank? && notification_control.#{notice.to_s}
      end
    EOF
    class_eval ws_notify, __FILE__, __LINE__
  end
  
=begin 
  def work_details
    [self.professional_qualification, self.occupation,
     self.company_name, self.industry,
     self.company_website, self.job_description].compact.join(' ')
  end
=end  
 
  def work_details
    unless self.work_informations.blank?
      work_arr = []
      self.work_informations.each do |work|
        work_arr << work.occupation
        work_arr << work.company_name
        work_arr << work.industry
        work_arr << work.company_website
        work_arr << work.job_description
      end
      return work_arr
    end
  end

  def female?
    gender.downcase == 'female'
  end

  def male?
    gender.downcase == 'male'
  end

  def premarital_lastname
    (female? and !maiden_name.blank?) ? maiden_name : last_name
  end

  def gender_str
    gender.downcase 
  end
  
  def location
    return Profile::NOWHERE if attributes['location'].blank?
    attributes['location']
  end
  
  def no_data?
    (created_at <=> updated_at) == 0
  end

  def has_wall_with profile
    return false if profile.blank?
    !Comment.between_profiles(self, profile).empty?
  end

  def website= val
    write_attribute(:website, fix_http(val))
  end
  def blog= val
    write_attribute(:blog, fix_http(val))
  end
  def flickr= val
    write_attribute(:flickr, fix_http(val))
  end
  
  # Friend Methods
  def friend_of? user
    user.in? friends
  end

  def followed_by? user
    user.in? followers
  end

  def following? user
    user.in? followings
  end

  def activate!
    self.is_active = StudentCheck.match_details?(self)
    save!
  end

  def deactivate!
    self.is_active = false
    save!
  end

  def toggle_status!
    self.toggle! :is_active
  end

  def profile_permissions
    if @permission_objects.nil?
      @permission_objects = []
      dbp = db_permissions
      @permission_objects = PERMISSION_FIELDS.map do |f|
        dbp[f].nil? ? permissions.build(:field => f, :permission => default_permission) : dbp[f]
      end
    end
    @permission_objects
  end

  def db_permissions
    if @db_permissions.nil? && !permissions.nil?
      @db_permissions = Hash.new
      permissions.each { |p| @db_permissions[p.field] = p }
    end
    @db_permissions
  end

  def field_permissions
    if @field_permissions.nil?
      @field_permissions = Hash.new
      dbp = db_permissions
      PERMISSION_FIELDS.each do |f|
        @field_permissions[f] = dbp[f].nil? ? default_permission.to_sym : dbp[f].permission.to_sym
      end
    end
    @field_permissions
  end

  def self.active_profiles
    self.active.all
  end

  def can_send_messages
    return true if user.can_send_messages && self.is_active?
    false
  end

  # Return False if the field is blank or doesnt exist on the model
  # Return True if the profile is your own profile
  # Return true if the field permission is for everyone
  # Return false if the field permissio is for myself
  # Return true or false based on if permission is for friends and the profile is a friend.
  def can_see_field(field, profile)
    return false if self.send(field).blank?
    return true if profile == self # logged in user same as profile user
   
    permissions =  field_permissions
    permission = permissions[field]
    return true if permission.nil?
    if permission == :Everyone
      return true
    elsif permission == :Myself
      return false
    else permission == :Friends
      return friend_of?(profile.user)
    end
  end

  def search query = '', options = {}
    if options[:key].blank?
      options.delete(:key)
      query ||= ''
      q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
      options.each {|key, value| q += " #{key}:#{value}"}
      find_options = self.user.is_admin? ? 
        { :conditions => ["users.email_verified = 1"],:order => "profiles.updated_at desc", :include => "user"} :
        { :conditions => ["is_active = 1"] }
      arr = Profile.find_by_contents(q, {}, find_options)
    else
      arr = search_by_keyword(options[:key],query)
    end
    arr
  end
  
  def search_by_keyword(key,val)
    return [] if val.blank?
    conditions=[]
    if key == "name"
      conditions = [" first_name LIKE ? OR last_name LIKE ? ","%#{val}%","%#{val}%"]
    elsif key == "location"
      conditions = [" location LIKE ?","%#{val}%" ]
    elsif key == "blood_group"
      conditions = [" blood_group LIKE ? ","%#{val}%"]
    elsif key == "year"
      conditions = [" profiles.group LIKE ? ","%#{val}%"]
    elsif key == "phone"
      conditions = [" mobile LIKE ? OR landline LIKE ? ","%#{val}%","%#{val}%"]
    elsif key == "address"
      conditions = [" address_line1 LIKE ? OR address_line2 LIKE ? ","%#{val}%","%#{val}%"]
    end
    if self.user.is_admin?
      Profile.with_email_verified.all(:conditions => conditions)
    else
      Profile.with_email_verified.active.all(:conditions => conditions)
    end
  end
   
  def self.today_birthday
    @profiles = self.all( 
      :conditions => ["month(date_of_birth) =? and day(date_of_birth) = ?", 
        Date.today.month, Date.today.day])
  end

  def self.today_anniversary
    @profiles = self.all(
      :conditions => ["month(anniversary_date) =? and day(anniversary_date) = ?", 
        Date.today.month, Date.today.day])
  end

  def birthdate_next
    nextb = nil
    current_year = Date.today.year
    unless date_of_birth.blank?
      year = date_of_birth.strftime("%m%d") < Date.today.strftime("%m%d") ? current_year + 1 : current_year
      nextb = Date.civil(year,date_of_birth.month,date_of_birth.day) rescue nil
    end
    nextb
  end
  
  def anniversary_next
    nexta = nil
    current_year = Date.today.year
    unless anniversary_date.blank?
      year = anniversary_date.strftime("%m%d") < Date.today.strftime("%m%d") ? current_year + 1 : current_year
      nexta = Date.civil(year,anniversary_date.month,anniversary_date.day) rescue nil 
    end
    nexta
  end

  def self.admins
    self.all(:conditions => ["users.is_admin = true"], :include => "user")
  end

  def self.admin_emails
    Profile.admins.map(&:email)
  end

  def to_ical_birthday_event
    unless date_of_birth.blank?
      summary = "#{full_name}'s birthday"
      description = "#{full_name} (#{group}) has their birthday today. They were born on #{date_of_birth.to_formatted_s(:long_ordinal)}."
      description += "\n Wish them on http://#{SITE}/profiles/#{to_param}"
      return ical_event(birthdate_next,summary,description,'Birthdays')
    end
  end

  def to_ical_anniversary_event
    unless anniversary_date.blank?
      summary = "#{full_name}'s anniversary"
      description = "#{full_name} (#{group}) has their anniversary today. They were married "
      description += ' to ' + spouse_name unless spouse_name.blank?
      description += " on #{anniversary_date.to_formatted_s(:long_ordinal)}."
      description += "\n Wish them on http://#{SITE}/profiles/#{to_param}"
      description.squeeze!(' ')
      return ical_event(anniversary_next,summary,description,'Anniversaries')
    end
  end
  
  def self.birthdays
    return @birthdays if @birthdays
    conditions = ['date_of_birth is not null']
    @birthdays = find(:all,:conditions => conditions).group_by {|d| d.date_of_birth.month }
    @birthdays.keys.each do |key|
      @birthdays[key].sort!{|a,b| a.date_of_birth.strftime("%e%m%Y") <=> b.date_of_birth.strftime("%e%m%Y") }
    end
    @birthdays
  end
  
  def self.anniversaries
    return @anniversaries if @anniversaries
    conditions = ['anniversary_date is not null']
    @anniversaries = find(:all,:conditions => conditions).group_by {|d| d.anniversary_date.month }
    @anniversaries.keys.each do |key|
      @anniversaries[key].sort!{|a,b| a.anniversary_date.strftime("%e%m%Y") <=> b.anniversary_date.strftime("%e%m%Y") }
    end
    @anniversaries
  end

  # Find people with birthdays around a given date.
  #
  #  :date - Date to anchor around. Defaults to today.
  #  :back - Number of days to go back. Defaults to 7.
  #  :forward - Number of days to look forward. Defaults to 14.

  
  def self.happy_day(days=self.happy_day_range,profile=nil,f='date_of_birth')
    clause = "#{f} is not null and date_format(#{f},'%m%d') in (?)"
    if profile
      clause += " and id in(?)"
      conditions = [clause,days,profile.all_friends.map(&:id)]
    else
      conditions = [clause,days]
    end
    self.active.all( 
      :select => "id,title,first_name,middle_name,last_name,profiles.group,#{f},default_permission" , 
      :conditions => conditions, :include => :permissions).group_by {|d| d.send(f).strftime("%m%d") }
  end

  def self.happy_day_range(options = {})
    unless @@days 
      options = options.reverse_merge(:date => Date.today, :back => 5, :forward => 10)
      start_date = options[:date] - options[:back].days
      end_date = options[:date] + options[:forward].days
      @@days = (start_date .. end_date).to_a.map{|d| d.strftime("%m%d")}
    end
    @@days
  end
  
  def self.find_all_happy_days(profile = nil, options = {})
    ref_date = options[:date] || Date.today
    days = self.happy_day_range(options)
    today_index = days.index(ref_date.strftime("%m%d"))
    birthdays = self.happy_day(days,profile,'date_of_birth')
    anniversaries = self.happy_day(days,profile,'anniversary_date')
    happy_days = {}
    [birthdays.keys + anniversaries.keys].flatten.uniq.sort.each do |date|
      happy_days[date] = {}
      happy_days[date][:birthdays] = birthdays.keys.any?{|d| d == date} ? birthdays[date] : []
      happy_days[date][:anniversaries] = anniversaries.keys.any?{|d| d == date} ? anniversaries[date] : []
      happy_days[date][:from_today] = days.index(date) - today_index
    end
    happy_days = happy_days.sort{|a,b| a[1][:from_today] <=> b[1][:from_today] }
    return  happy_days  
    
  end 
  
  def batch_mates(opts)
    Profile.active.group(self.group).paginate(opts)
  end
  
  def self.batch_details(group, opts)
    Profile.active.group(group).name_ordered.paginate(opts)
  end
  
  def self.batch_names(group)
    active.group(group).name_ordered.all(:select => 'title,first_name, middle_name, last_name, id')
  end

  def self.get_batch_count
    active.all(:group => 'profiles.group', :order => 'profiles.group', :select => 'profiles.group, count(*) as count')
  end

  def all_friends
    @my_friends ||= (self.followings+self.friends+[self]).uniq.compact 
  end
   
  def find_feed_items
    feed_items =[]
    self.feed_items.each do|feed_item|
      feed_items << feed_item if feed_item.item
    end
    return feed_items
  end
  
  def marker=(marker_hash)
    if (marker_hash[:lat].blank? or marker_hash[:lng].blank? or (marker_hash[:lat] == '0' and marker_hash[:lng] == '0'))
      marker.destroy if marker
      return
    elsif marker
      marker.update_attributes(marker_hash)
    else
      build_marker(marker_hash)
    end
  end

  private

  before_update :permission_sync
  after_update  :create_feed_item 
  
  before_save   :remove_blank_education, :strip_names, :remove_blank_work_information
  after_create :create_notifications
  def ical_event(event_date,summary,description,category)
    return nil if event_date.blank?
    event = Icalendar::Event.new
    event.start = event_date.strftime("%Y%m%dT%H%M%S")
    event.duration = 'PT24H'
    event.summary = summary
    event.description = description
    event.add_category(category) if category
    event.add_recurrence_rule('FREQ=YEARLY')
    #event.uid = "#{self.id}profile@risealumni.base"
    return event
  end

  def create_feed_item
    feed_item = FeedItem.find_or_initialize_by_item_id_and_item_type(self.id,'Profile')
    create_feed = feed_item.new_record?
    feed_item.save
    self.feed_items << feed_item if create_feed
  end
  
  def permission_sync
    return true if permissions.nil?
    permissions.delete permissions.select {|p| p.permission == default_permission}
  end

  def remove_blank_education
    educations.delete_if do |e|
      e.highschool_name.blank? and e.education_from_year.blank? and e.education_to_year.blank? and e.university.blank?
    end
  end
  def remove_blank_work_information
    work_informations.delete_if do |w|
      w.company_name.blank? and w.occupation.blank? and w.industry.blank? and w.company_website.blank? and w.job_description .blank?
    end
  end

  def create_notifications
    if notification_control.blank?
      build_notification_control
    end
  end

  def strip_names
    %w[first_name middle_name last_name].each do |f|
      v = self.read_attribute(f)
      self.write_attribute(f,v.strip.titleize) unless v.blank?
    end
  end
  
  protected
  def fix_http str
    return '' if str.blank?
    str.starts_with?('http') ? str : "http://#{str}"
  end

end
