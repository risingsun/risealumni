class Announcement < ActiveRecord::Base
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :message

  named_scope :current, :conditions => "starts_at <= now() AND ends_at >= now()"

  named_scope :hide, lambda {|hide_time| {:conditions => ["updated_at > ? OR starts_at > ?", hide_time,hide_time]}}

  def self.current_announcements(hide_time)
    hide_time.nil? ? current.all : current.hide(hide_time).all
  end
end
