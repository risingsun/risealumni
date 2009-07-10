class TweetsWorker < Workling::Base
  include ActionView::Helpers::TextHelper
  include ActionController::UrlWriter

  def initialize
    @@twitter = Twitter::Client.from_config('twitter.yml' , 'user' )
  end

  def send_blog_tweets(blog)
    begin
      blo = Blog.find(blog)
      @@twitter.status(:post, "New Blog " + truncate(blo.title, :length => 115) + profile_blog_url(blo.profile,blo))
    rescue
    end
  end

  def send_event_tweets(event)
    begin
      evt = Event.find(event)
      @@twitter.status(:post, "New Event " + truncate(evt.title, :length => 115) + show_event_url(evt))
    rescue
    end
  end

  def send_activation_tweets(profile)
    begin
      prof = Profile.find(profile)
      @@twitter.status(:post, "#{SITE_NAME} welcomes #{prof.full_name} of #{prof.group} group for joining us. #{profile_url(prof)}")
    rescue
    end
  end

end