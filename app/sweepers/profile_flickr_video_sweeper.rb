class ProfileFlickrVideoSweeper < ActionController::Caching::Sweeper
  observe Profile
  def after_update(profile)
    expire_cache(profile)
  end
  
  def expire_cache(profile)
    expire_fragment "profile_#{profile.id}/profile_flickr_pics_and_video#{profile.id}"
    expire_fragment "profile_#{profile.id}/profile_#{profile.id}"
  end
  
end