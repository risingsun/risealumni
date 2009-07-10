# == Schema Information
# Schema version: 2
#
# Table name: blogs
#
#  id         :integer(11)   not null, primary key
#  title      :string(255)   
#  body       :text          
#  profile_id :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#  is_sent    :boolean(1)    
#

class Blog < ActiveRecord::Base
  has_many :comments, :as => :commentable, :order => "comments.created_at DESC"
  belongs_to :profile
  validates_presence_of :title, :body
  
  acts_as_ferret :fields => {:title => {:store => :yes}, 
    :body => {:store => :yes}} , :remote => true                  
                             
  acts_as_taggable
  named_scope :date_order, lambda {|o| {:order => "created_at #{o}"}}
  named_scope :unsent_blogs,:conditions => ["is_sent =?", false] 
  named_scope :public , :conditions => ["public = ?", true]
  named_scope :by_month_year, lambda {|month,year| {:conditions => ["monthname(created_at)=? and year(created_at)=?",month,year]}}
  named_scope :latest_limit, lambda {|l| {:limit => l}}
  
  
  def after_create
    feed_item = FeedItem.create(:item => self)
    ([profile] + profile.friends + profile.followers).each{ |p| p.feed_items << feed_item }
  end
  
  def to_param
    "#{self.id}-#{title.to_safe_uri}"
  end
    
  def latest_comments(limit = :all)
    comments.all(:limit => limit)
  end
  
  def sent_by
    profile.full_name
  end
  
  def self.search_blog(query = '', options = {})
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = Blog.find_by_contents(q)
    arr
  end
  
  def self.blog_groups
    find(:all, 
         :select => "count(*) as cnt, MONTHNAME(created_at) as month,YEAR(created_at) as year" ,         
         :group => "month,year",
         :order => "year DESC, MONTH(created_at) DESC" )
  end

  def commented_users(profile)
    self.comments.comments_without_self(profile).uniq
  end
end
