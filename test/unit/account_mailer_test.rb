require File.dirname(__FILE__) + '/../test_helper'

class AccountMailerTest < ActiveSupport::TestCase

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.default_url_options[:host] = 'localhost'
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
    @u = users(:user)
  end

  def test_signup
    AccountMailer.deliver_signup(@u)
    assert !ActionMailer::Base.deliveries.empty?

    sent = ActionMailer::Base.deliveries.first
    assert_equal [@u.profile.email], sent.to
    #assert_match "Signup info", sent.subject
    assert_match @u.login, sent.body
  end

  def test_forgot_password
    AccountMailer.deliver_forgot_password(@u.profile.email, @u.f, @u.login,'new_pass')
    assert !ActionMailer::Base.deliveries.empty?

    sent = ActionMailer::Base.deliveries.first
    assert_equal [@u.profile.email], sent.to
    assert_match @u.f, sent.body
    assert_match @u.login, sent.body
    assert_match 'new_pass', sent.body
  end
  
  def test_new_email_request
    ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
    sent = AccountMailer.deliver_new_email_request(@u)
    #assert_equal ["info@risingsuntech.net"], sent.to
    #assert_equal profiles(:user), sent.body['profile']
    assert_equal 'eded0c94d92e49882b60bd5c4e6d9d9b19ec2597', @u.email_verification
    assert_match "New email requested", sent.subject
   
  end
  
  def test_email_confirmed_by_user
    u = users(:user)
    activation  = u.profile.is_active ? 'Activated':'Requires Activation'
    response = AccountMailer.deliver_email_confirmed_by_user(u)
    assert_equal "[#{SITE_NAME} #{activation}] #{u.profile.full_name} (#{u.profile.group})", response.subject
    assert_equal Profile.admin_emails, response.to
    #assert_equal MAILER_FROM_ADDRESS, response.from
  end
  
  def test_should_send_bday_greeting
    p = profiles(:user)
    response = AccountMailer.deliver_bday_greeting(p)
    assert_equal "Happy Birthday, #{p.first_name.titlecase}", response.subject
    assert_equal [p.email], response.to
    #assert_equal ["info@risingsuntech.net"], response.from
  end
  
  def test_should_anniversary_greeting
    p = profiles(:user)
    response = AccountMailer.deliver_anniversary_greeting(p)
    assert_equal "Best Wishes on your Anniversary, #{p.first_name.titlecase}", response.subject
    assert_equal [p.email], response.to
    #assert_equal ["info@risingsuntech.net"], response.from
  end
  
  def test_should_daily_signup_report
    response = AccountMailer.deliver_daily_signup_report
    assert_equal "[#{SITE_NAME} Daily Report] User Activations", response.subject
    assert_equal Profile.admin_emails, response.to
  end
  
  
  private
  def read_fixture(action)
    IO.readlines("#{FIXTURES_PATH}/account_mailer/#{action}")
  end

  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end