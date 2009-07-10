# == Schema Information
# Schema version: 2
#
# Table name: users
#
#  id                          :integer(11)   not null, primary key
#  login                       :string(255)   
#  crypted_password            :string(40)    
#  salt                        :string(40)    
#  created_at                  :datetime      
#  updated_at                  :datetime      
#  remember_token              :string(255)   
#  remember_token_expires_at   :datetime      
#  is_admin                    :boolean(1)    
#  can_send_messages           :boolean(1)    default(TRUE)
#  time_zone                   :string(255)   default("UTC")
#  email_verification          :string(255)   
#  email_verified              :boolean(1)    
#  last_login_date             :date          
#  first_referral_person_name  :string(255)   
#  first_referral_person_year  :string(255)   
#  second_referral_person_name :string(255)   
#  second_referral_person_year :string(255)   
#  third_referral_person_name  :string(255)   
#  third_referral_person_year  :string(255)   
#  additional_message          :text          
#  requested_new_email         :string(255)   
#

class User < ActiveRecord::Base
  has_one :profile, :dependent => :nullify
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :terms_of_service, :email, :profile_attributes, :references
  attr_protected :is_admin, :can_send_messages
  
  validates_acceptance_of   :terms_of_service, :on => :create, :message => "Must be accepted"
  validates_confirmation_of :password, :if => :password_required?
  validates_presence_of     :password, :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_presence_of     :login,:unless => :is_facebook_user?
  validates_length_of       :login, :within => 3..25, :unless => :is_facebook_user?
  validates_uniqueness_of   :login, :case_sensitive => false, :unless => :is_facebook_user?
  validates_format_of       :login, :with => /^\w+$/i, :message => "can only contain letters and numbers.", :unless => :is_facebook_user?
  validates_format_of       :requested_new_email, 
    :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
    :message=>'does not look like an email address.',
    :if => proc {|obj| !obj.requested_new_email.blank?}
  validates_captcha(:unless => :is_facebook_user?)if RAILS_ENV=='production'
  validates_presence_of :profile
  validates_uniqueness_of :facebook_uid,:if => :is_facebook_user?, :message => "Facebook id has already been taken"

  before_save :encrypt_password
  before_save :require_references
  
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w( time_zone time_zone )

  validates_associated :profile, :on => :create

  def match_details
    StudentCheck.match_details?(self.profile, false)
  end
  
  def require_references
    if !profile.is_active && !match_details && [first_referral_person_name, first_referral_person_year,
      second_referral_person_name,second_referral_person_year,
      third_referral_person_name, third_referral_person_year, additional_message ].reject!(&:blank?).blank?
      errors.add( :references, 
                  "Hey! It seems our database from school is incomplete, or has a poor spelling of your name.
                  Do you mind giving us some references so we can activate you manually instead?") 
      return false
    end
    true
  end
  
  def profile_attributes=(profile_attributes)
    p = Profile.find_by_email(profile_attributes[:email]) rescue nil
      if p && p.user && !p.user.email_verified
      p.user.destroy # Destroy the existing user of that profile
      p.destroy
    end
    self.build_profile(profile_attributes)
  end

  def after_destroy
    profile.deactivate! unless profile.blank?
  end

  def email
    profile.email
  end
  
  def f(tr=15)
    profile.f(tr)
  end

  def full_name
    profile.full_name
  end
  
  def can_mail? user
    can_send_messages? && profile.is_active?
  end

  def is_facebook_user?
    facebook_uid > 0 unless facebook_uid.nil?
  end
  
  # Authenticates a user by their login name and unencrypted password.
  # Returns the user or nil.
  def self.authenticate(login, password)
    return if login.blank? or password.blank?
    if login.include? "@" #Check if the login name contains the email symbol
      u = Profile.find_by_email(login).user rescue nil
    else
      u = User.find(:first,:conditions => ['login = ?',login]) # need to get the salt
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_me!
    self.remember_token_expires_at = 10.years.from_now
    self.remember_token = UUID.random_create.to_s + '-' + UUID.random_create.to_s if self.remember_token.nil?
    save!
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  def forgot_password!
    @forgot = true
    self.password = UUID.random_create.to_s[0,8]
    self.password_confirmation = password
    encrypt_password
    self.save!
    self.password
  end
  
  def change_password(current_password, new_password, confirm_password)
    sp = User.encrypt(current_password, self.salt)
    errors.add( :password, "The password you supplied is not the correct password.") and
      return false unless sp == self.crypted_password
    errors.add( :password, "The new password does not match the confirmation password.") and
      return false unless new_password == confirm_password
    errors.add( :password, "The new password may not be blank.") and
      return false if new_password.blank?
    
    self.password = new_password
    self.password_confirmation = confirm_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
    self.crypted_password = encrypt(new_password)
    save
  end

  def generate_confirmation_hash!(secret_word = "pimpim")
    self.email_verification = Digest::SHA1.hexdigest(secret_word + DateTime.now.to_s)
  end

  def confirm_email!
    self.email_verified = true
    self.email_verification = nil
  end
  
  def match_confirmation?(user_hash)
    (user_hash.to_s == self.email_verification)
  end
  
  def matched_referrers
    f = ['first','second','third'].select do |item|
      rname = self[item+'_referral_person_name']
      ryear = self[item+'_referral_person_year']
      !rname.blank? or !ryear.blank? 
    end
    f.map do |item|
      rname = self[item+'_referral_person_name']
      ryear = self[item+'_referral_person_year']
      first_name = rname.split.first
      last_name = rname.split.last
      t = 'Not Found'
      u = User.find(:first,
        :conditions => 
          ["profiles.first_name =? and profiles.last_name =? and profiles.group = ? and profiles.is_active = true" , 
          first_name, last_name, ryear], :include => "profile") rescue nil
      t = 'Active User' if u
      unless u
        u = StudentCheck.find_by_first_name_and_last_name_and_year(:first,first_name, last_name, ryear)
        t = 'Unknown User' if u
      end
      { :match => !u.blank?, 
        :name => u.blank? ? rname : u.full_name, 
        :year => u.blank? ? ryear : u.profile.group,
        :t => t }
    end
  end
  
  def email_confirmed?
    self.email_verified == 1
  end
  
  def record_login!
    self.last_login_date = Date.today
  end
    
  def request_email_change!(new_email)
    self.errors.add( :requested_new_email, "Cannot be Blank") and
      return false if new_email.blank?
    self.requested_new_email = new_email
    self.generate_confirmation_hash!
    self.save
  end
    
  protected

  # before filter 
  def encrypt_password
    return if password.blank? && is_facebook_user?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if
    new_record? || @forgot
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    if is_facebook_user?
      @password_required = false
    else
      @password_required ||= crypted_password.blank? || !password.blank?
    end
  end
end

