class NotificationControl < ActiveRecord::Base

  belongs_to :profile
  
  validates_presence_of :profile
  
  before_save :reset_news_notification, :reset_event_notification, :reset_follow_notification, 
              :reset_delete_friend_notification, :reset_message_notification, :reset_blog_comment_notification,
              :reset_profile_comment_notification
  
            
  NO_NOTIFICATION = 0 
  ALL_NOTIFICATION = 1
  ONLY_EMAIL = 2
  ONLY_MESSAGE = 3
  
  [:news_email, :news_message, :event_email, :event_message, :message_email, :message_message, :blog_comment_email,
   :blog_comment_message, :profile_comment_email, :profile_comment_message, :follow_email, :follow_message, :delete_friend_email,
   :delete_friend_message].each do |notice| 
    ws_notify = <<-EOF
      def #{notice.to_s}=(val)
          @#{notice} = true if val== "1"
      end
    EOF
    class_eval ws_notify, __FILE__, __LINE__
  end
  
  def news_email
    return true if news == ALL_NOTIFICATION or news == ONLY_EMAIL 
  end
  
  def news_message
    return true if news == ALL_NOTIFICATION or news == ONLY_MESSAGE
  end
  
  def event_email
    return true if event == ALL_NOTIFICATION or event == ONLY_EMAIL 
  end
  
  def event_message
    return true if event == ALL_NOTIFICATION or event == ONLY_MESSAGE
  end
  
  def message_email
    return true if  message == ALL_NOTIFICATION or  message == ONLY_EMAIL 
  end
  
  def message_message
    return true if message == ALL_NOTIFICATION or message == ONLY_MESSAGE
  end
  
  def blog_comment_email
    return true if  blog_comment == ALL_NOTIFICATION or  blog_comment == ONLY_EMAIL 
  end
  
  def blog_comment_message
    return true if blog_comment == ALL_NOTIFICATION or blog_comment == ONLY_MESSAGE
  end
  
  def profile_comment_email
    return true if  profile_comment == ALL_NOTIFICATION or  profile_comment == ONLY_EMAIL 
  end
  
  def profile_comment_message
    return true if profile_comment == ALL_NOTIFICATION or profile_comment == ONLY_MESSAGE
  end
  
  def follow_email
    return true if follow == ALL_NOTIFICATION or follow == ONLY_EMAIL 
  end
  
  def follow_message
    return true if follow == ALL_NOTIFICATION or follow == ONLY_MESSAGE
  end
  
  def delete_friend_email
    return true if delete_friend == ALL_NOTIFICATION or delete_friend == ONLY_EMAIL 
  end
  
  def delete_friend_message
    return true if delete_friend == ALL_NOTIFICATION or delete_friend == ONLY_MESSAGE
  end
  
  def reset_news_notification
    self.news = 2 
    return if new_record?
    news_email = instance_variable_get(:@news_email)
    news_message = instance_variable_get(:@news_message) 
    if news_email && news_message
      self.news = ALL_NOTIFICATION
    elsif news_email && !news_message
      self.news = ONLY_EMAIL 
    elsif !news_email && news_message
      self.news = ONLY_MESSAGE
    elsif !news_email && !news_message
      self.news = NO_NOTIFICATION
    end    
  end
  
  def reset_event_notification
    self.event = 2
    return  if new_record?
    event_email = instance_variable_get(:@event_email)
    event_message = instance_variable_get(:@event_message) 
    if event_email && event_message
      self.event = ALL_NOTIFICATION
    elsif event_email && !event_message
      self.event = ONLY_EMAIL 
    elsif !event_email && event_message
      self.event = ONLY_MESSAGE
    elsif !event_email && !event_message
      self.event = NO_NOTIFICATION
    end    
  end
  
  def reset_message_notification
    self.message = 2 
    return  if new_record?
    message_email = instance_variable_get(:@message_email)
    message_message = instance_variable_get(:@message_message) 
    if message_email && message_message
      self.message = ALL_NOTIFICATION
    elsif message_email && !message_message
      self.message = ONLY_EMAIL 
    elsif !message_email && message_message
      self.message = ONLY_MESSAGE
    elsif !message_email && !message_message
      self.message = NO_NOTIFICATION
    end    
  end
  
  
  def reset_blog_comment_notification
    self.blog_comment = 2 
    return  if new_record?
    blog_comment_email = instance_variable_get(:@blog_comment_email)
    blog_comment_message = instance_variable_get(:@blog_comment_message) 
    if blog_comment_email && blog_comment_message
      self.blog_comment = ALL_NOTIFICATION
    elsif blog_comment_email && !blog_comment_message
      self.blog_comment = ONLY_EMAIL 
    elsif !blog_comment_email && blog_comment_message
      self.blog_comment = ONLY_MESSAGE
    elsif !blog_comment_email && !blog_comment_message
      self.blog_comment = NO_NOTIFICATION
    end    
  end
  
  
  def reset_profile_comment_notification
    self.profile_comment = 2 
    return  if new_record?
    profile_comment_email = instance_variable_get(:@profile_comment_email)
    profile_comment_message = instance_variable_get(:@profile_comment_message) 
    if profile_comment_email && profile_comment_message
      self.profile_comment = ALL_NOTIFICATION
    elsif profile_comment_email && !profile_comment_message
      self.profile_comment = ONLY_EMAIL 
    elsif !profile_comment_email && profile_comment_message
      self.profile_comment = ONLY_MESSAGE
    elsif !profile_comment_email && !profile_comment_message
      self.profile_comment = NO_NOTIFICATION
    end    
  end
  
  def reset_follow_notification
    self.follow = 2 
    return  if new_record?
    follow_email = instance_variable_get(:@follow_email)
    follow_message = instance_variable_get(:@follow_message) 
    if follow_email && follow_message
      self.follow = ALL_NOTIFICATION
    elsif follow_email && !follow_message
      self.follow = ONLY_EMAIL 
    elsif !follow_email && follow_message
      self.follow = ONLY_MESSAGE
    elsif !follow_email && !follow_message
      self.follow = NO_NOTIFICATION
    end    
  end
  
  def reset_delete_friend_notification
    self.delete_friend = 2 
    return  if new_record?
    delete_friend_email = instance_variable_get(:@delete_friend_email)
    delete_friend_message = instance_variable_get(:@delete_friend_message) 
    if delete_friend_email && delete_friend_message
      self.delete_friend = ALL_NOTIFICATION
    elsif delete_friend_email && !delete_friend_message
      self.delete_friend = ONLY_EMAIL 
    elsif !delete_friend_email && delete_friend_message
      self.delete_friend = ONLY_MESSAGE
    elsif !delete_friend_email && !delete_friend_message
      self.delete_friend = NO_NOTIFICATION
    end    
  end
  
end
