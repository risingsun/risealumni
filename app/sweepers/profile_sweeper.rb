class ProfileSweeper < ActionController::Caching::Sweeper
  observe Profile

  def after_save(profile)
    expire_cache(profile)
  end

  def before_update(profile)
    if TWITTER_ENABLED && profile.valid? && profile.is_active_changed? && profile.is_active
      TweetsWorker.async_send_activation_tweets(profile.id)
    end
  end

  def expire_cache(profile)
    if profile.is_active?
      expire_fragment 'recent_members'
      expire_fragment 'batch_count'
    end
  end

end
