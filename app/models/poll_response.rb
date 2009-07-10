class PollResponse < ActiveRecord::Base

  validates_presence_of :profile
  validates_presence_of :poll_option
  validates_presence_of :poll_id
  validates_uniqueness_of :profile_id, :scope => :poll_id, :message => 'has already voted.'
  
  belongs_to :profile
  belongs_to :poll_option, :counter_cache => true
  belongs_to :poll
  
  after_save :update_poll_votes_count
  
  def update_poll_votes_count
    votes_count = PollOption.sum(:poll_responses_count, :conditions => {:poll_id => self.poll_id})
    self.poll.votes_count = votes_count
    self.poll.save!
  end
end
