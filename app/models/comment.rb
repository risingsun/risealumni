# == Schema Information
# Schema version: 2
#
# Table name: comments
#
#  id               :integer(11)   not null, primary key
#  comment          :text          
#  created_at       :datetime      not null
#  updated_at       :datetime      not null
#  profile_id       :integer(11)   
#  commentable_type :string(255)   default(""), not null
#  commentable_id   :integer(11)   not null
#  is_denied        :integer(11)   default(0), not null
#  is_reviewed      :boolean(1)    
#

class Comment < ActiveRecord::Base
  
  validates_presence_of :comment, :profile

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :profile
 
  named_scope :profile_comments, :conditions => ["commentable_type='Profile'"]
  named_scope :ordered, :order => 'created_at desc'
  named_scope :comments_without_self, lambda {|id| { :conditions => ['profiles.id != ? and commentable_type = ?',id, "Blog"],:joins => :profile }}
 
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end
  
  
  def self.between_profiles profile1, profile2
    ordered.profile_comments.all({
        :conditions => ["(profile_id=? and commentable_id=?) or (profile_id=? and commentable_id=?)",
        profile1.id, profile2.id, profile2.id, profile1.id]
    })
  end
  
  def self.recent_comments(limit = 6)
    ordered.profile_comments.all(:limit => limit)
  end
  
end
