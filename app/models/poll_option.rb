class PollOption < ActiveRecord::Base

  belongs_to :poll
  validates_uniqueness_of :option, :scope => :poll_id, :message => 'has already.'
  validates_length_of :option, :maximum => 25
  has_many :poll_responses, :dependent => :destroy
 
 
  def votes_percentage(precision = 1)
    total_votes = poll.poll_responses.count
    percentage = total_votes.eql?(0) ? 0 : ((poll_responses.count.to_f/total_votes.to_f)*100)
    "%01.#{precision}f" % percentage
  end
  
end
