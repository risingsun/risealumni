class AccountMailer < ActionMailer::Base
  
  def signup(user)
    @subject         = "[#{SITE_NAME} Signup] #{user.profile.first_name.titlecase}, Thanks for joining!"
    @recipients      = user.profile.email
    @body['user']    = user
    @body['hash']    = user.email_verification
    @body['user_id'] = user.id
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def forgot_password(email, name, login, password)
    @subject         = "[#{SITE_NAME} Notice] Password Reset"
    @body['user']    = [email, name, login, password]
    @recipients      = email
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def new_email_request(user)
    @subject                   = "[#{SITE_NAME} Notice] New email requested"
    @recipients                = user.requested_new_email
    @body['profile']           = user.profile
    @body['name']              = user.profile.full_name
    @body['user_verification'] = user.email_verification
    @from                      = MAILER_FROM_ADDRESS
    @sent_on                   = Time.new
  end
  
  def email_confirmed_by_user(user)
    @activation               = user.profile.is_active ? 'Activated':'Requires Activation'
    @subject                  = "[#{SITE_NAME} #{@activation}] #{user.profile.full_name} (#{user.profile.group})"
    @recipients               = Profile.admin_emails
    @body['user']             = user
    @body['activation']       = @activation
    @from                     = MAILER_FROM_ADDRESS
    @sent_on                  = Time.new
  end

  def bday_greeting(profile)
    @subject         = "Happy Birthday, #{profile.first_name.titlecase}"
    @recipients      = profile.email
    @body['profile'] = profile
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end
  
  def anniversary_greeting(profile)
    @subject         = "Best Wishes on your Anniversary, #{profile.first_name.titlecase}"
    @recipients      = profile.email
    @body['profile'] = profile
    @from            = MAILER_FROM_ADDRESS
    @sent_on         = Time.new
  end

  def daily_signup_report(profiles)
    @subject          = "[#{SITE_NAME} Daily Report] User Activations"
    @recipients       = Profile.admin_emails
    @body['profiles'] = profiles
    @from             = MAILER_FROM_ADDRESS
    @sent_on          = Time.new
  end
  
end
