class MessagesSweeper < ActionController::Caching::Sweeper
  observe Message  
  
  def after_create(message)
    expire_cache(message)
  end
  def after_destroy(message)
    expire_cache(message)
  end
  def after_save(message)
    expire_cache(message)
  end
  def expire_cache(message)
    expire_fragment "profile_#{message.sender_id}/message/inbox"
    expire_fragment "profile_#{message.receiver_id}/message/inbox"
    expire_fragment "profile_#{message.sender_id}/message/sent"
    expire_fragment "profile_#{message.receiver_id}/message/sent"
  end
end 