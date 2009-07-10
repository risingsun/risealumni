module MessagesHelper
  
  def unread_message_class(message, page)
    !message.read && page == "inbox" ? "unread_message"  : ""
  end
  
  def cache_message_name(profile,page)
    "profile_#{profile.id}/message/#{page}"
  end
  
end
