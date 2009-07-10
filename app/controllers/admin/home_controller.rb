class Admin::HomeController < ApplicationController
  layout "admin"

  def index
  end

  def admin_blogs
    return unless @p.user.is_admin
    @blogs = @p.unsent_blogs
  end

  def send_blog
    blog = Blog.find(params[:id])
    blog.update_attribute(:is_sent,true)
    @profiles = Profile.active_profiles
    admin_sender = Profile.admins.first
    @profiles.each do|profile|
      # If the user wants to be notified by email
      ArNotifier.deliver_sent_news(blog,profile) if profile.wants_news_email_notification?
      # if the user wants to be notified by site message
      admin_sender.sent_messages.create(:subject => "[#{SITE_NAME} News] #{blog.title} by #{blog.sent_by}",
                                        :body => blog.body, :receiver => profile, :system_message => true) if profile.wants_news_message_notification?
    end
    # Send tweet
    TweetsWorker.async_send_blog_tweets(blog.id) if TWITTER_ENABLED
    redirect_back_or_default('/')
    flash[:notice] = "Mail was successfully sent"
  end

  # TODO COMPLETE THIS!
  # Need to process and clear admin controlled caches
  def refresh_cache
    return unless @p.user.is_admin
    return unless request.delete?
    expire_fragment('app_flickr_pics')
    flash[:notice] = "Cache Cleared!"
    redirect_back_or_default('/admin')
  end

  def admin_home

  end

  def google_map_locations
    @profiles = Profile.active.all.select{|f|f.can_see_field('marker',@p)}
  end

  private

  def allow_to
    super :admin, :all => true
  end

end
