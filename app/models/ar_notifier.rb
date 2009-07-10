class ArNotifier < ActionMailer::ARMailer
  
  helper :profiles, :application
  def sent_news(blog,user)
    @subject      = "[#{SITE_NAME} News] #{blog.title} by #{blog.sent_by}"
    @recipients   = user.email
    @body['blog'] = blog
    @body['user'] = user
    @from         = MAILER_FROM_ADDRESS
    @sent_on      = Time.new
    content_type("text/html")
  end
  
  def send_event_mail(profile,event)
    @subject         = "[#{SITE_NAME} Events] Latest event"
    @recipients      = profile.email
    @body['profile'] = profile
    @body['event']   = event
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
    content_type("text/html")
  end
  
  def message_send(message,p)
    @subject         = "[#{SITE_NAME} Message] #{p.full_name} sent you a message : #{message.subject}"
    @recipients      = message.receiver.email
    @body['message'] = message
    @body['p']       = p
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
    content_type("text/html")
  end
  
  def comment_send_on_blog(comment,profile,p)
    @subject         = "[#{SITE_NAME} Blog] #{p.full_name} wrote on your blog"
    @recipients      = profile.email
    @body['comment'] = comment
    @body['p']       = p
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def comment_send_on_blog_to_others(comment,profile,p,blog_profile)
    @subject         = "[#{SITE_NAME} Blog] #{comment.profile.full_name} wrote on #{blog_profile.full_name} blog"
    @recipients      = profile.email
    @body['comment'] = comment
    @body['p']       = p
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def comment_send_on_profile(comment,profile,p)
    @subject         = "[#{SITE_NAME} Wall] #{p.full_name} wrote on your wall"
    @recipients      = profile.email
    @body['comment'] = comment
    @body['p']       = p
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def feedback_mail(feedback,rec_profile)
    @subject          = "[#{SITE_NAME} Feedback] #{feedback.subject}"
    @recipients       = ADMIN_RECIPIENTS
    @cc               = rec_profile
    @body['feedback'] = feedback
    @body['name']     = feedback.profile ? feedback.profile.full_name : feedback.name
    @body['email']    = feedback.profile ? feedback.profile.email : feedback.email
    @from             = MAILER_FROM_ADDRESS
    @sent_on          = Time.new
  end

  def follow inviter, invited, description
    @subject             = "[#{SITE_NAME} Notice] #{inviter.full_name} is now following you"
    @recipients          = invited.email
    @body['inviter']     = inviter
    @body['invited']     = invited
    @body['description'] = description
    @from                = MAILER_FROM_ADDRESS
    @sent_on             = Time.new
  end
  
  def delete_friend user, friend
    @subject        = "[#{SITE_NAME} Notice] Delete friend notice"
    @recipients     = friend.email
    @body['user']   = user
    @body['friend'] = friend
    @from           = MAILER_FROM_ADDRESS
    @sent_on        = Time.new
  end
  
  def user_status(profile)
    @subject         = "[#{SITE_NAME} Notice] New status change"
    @recipients      = profile.email
    @body['profile'] = profile
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def invite(student)
    @subject         = "Hi #{student.full_name}, Get back to the future with #{SITE_NAME} on http://#{SITE}"
    @recipients      = student.emails
    @body['student'] = student
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def invite_batchmates(invitation)
    @subject       = "[#{SITE_NAME} Invitation] Your batch mates are looking for you!"
    @recipients    = invitation.email
    @body['email'] = invitation.email
    @body['inviter'] = invitation.profile
    @from          = MAILER_FROM_ADDRESS
    @sent_on       = Time.new
  end
end
