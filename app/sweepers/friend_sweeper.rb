class FriendSweeper < ActionController::Caching::Sweeper
  observe Friend  
  
  def after_create(friend)
    expire_cache(friend)
  end
  def after_destroy(friend)
    expire_cache(friend)
  end
  
  def expire_cache(friend)
    expire_fragment "profile_#{friend.inviter_id}/friends"
    expire_fragment "profile_#{friend.invited_id}/friends"
    expire_fragment "profile_#{friend.inviter_id}/followings"
    expire_fragment "profile_#{friend.invited_id}/followings"
    expire_fragment "profile_#{friend.inviter_id}/followers"
    expire_fragment "profile_#{friend.invited_id}/followers"
  end
end
  
