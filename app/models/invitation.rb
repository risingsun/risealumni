class Invitation < ActiveRecord::Base
  
  belongs_to :profile
  validates_presence_of :email
  validates_presence_of :profile
  validates_uniqueness_of :email, :scope => :profile_id
  validates_format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message=>'does not look valid.<br/>'
  
  attr_accessor :emails
  attr_accessor :status
  before_save :check_email, :set_status, :update_timestamp
  after_save :send_invite
  
  def recent?(d = 7)
    updated_at >= (Date.today - d.days)
  end
  
  private
  
  def check_email
    p = Profile.find_by_email(self.email)
    if p
      self.status = :already_existing
      self.profile = p
      return false
    end
    return true
  end

  def set_status
    self.status = self.new_record? ? :new : (self.recent? ? :already_invited : :reinviting)
    return self.status != :already_invited
  end
  
  def update_timestamp
    self.updated_at = Date.today if (self.status == :reinviting)
    return true
  end
  
  def send_invite
    ArNotifier.deliver_invite_batchmates(self) if (self.status != :already_invited and self.status != :already_existing)
    true
  end
  
end
