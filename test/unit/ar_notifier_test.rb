require File.dirname(__FILE__) + '/../test_helper'

class ArNotifierTest < ActiveSupport::TestCase
  
  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.default_url_options[:host] = 'localhost'
  end
  
  def test_send_news
    n = blogs(:sixteen)
    u = profiles(:user)
    response = ArNotifier.deliver_sent_news(n, u)
    assert_equal "[#{SITE_NAME} News] #{n.title} by #{n.sent_by}", response.subject
    assert_equal [u.email], response.to
    assert response.body =~ /Blog post titled/
    assert response.body =~ /#{n.title}/
    assert response.body =~ /#{n.sent_by}/
    assert response.body =~ /#{n.body}/
  end

  def test_send_event_mail
    p = profiles(:user)
    e = events(:event1)
    response = ArNotifier.deliver_send_event_mail(p, e)
    assert_equal "[#{SITE_NAME} Events] Latest event", response.subject
    assert_equal [p.email], response.to
    assert response.body =~ /#{e.title}/
    assert response.body =~ /#{e.description}/
    #assert_equal ["info@risingsuntech.net"], response.from
  end
  
  def test_user_status
    p = profiles(:user)
    response = ArNotifier.deliver_user_status(p)
    assert_equal "[#{SITE_NAME} Notice] New status change", response.subject
    assert_equal [p.email], response.to
    #assert_equal ["info@risingsuntech.net"], response.from
    assert_equal "Your profile has now been #{p.status}.\n\nThanks,\n\n#{SITE_NAME} Alumni Team", response.body
  end
  
  def test_message_send
    p = profiles(:user2)
    m = messages(:user_to_user2)
    response = ArNotifier.deliver_message_send(m, p)
    assert_equal "[#{SITE_NAME} Message] #{p.full_name} sent you a message : #{m.subject}", response.subject
    assert_equal [p.email], response.to   
  end
  
  def test_comment_send_on_blog
    c = comments(:first)
    pr = profiles(:user)
    p = profiles(:user2)
    response = ArNotifier.deliver_comment_send_on_blog(c, pr, p)
    assert_equal "[#{SITE_NAME} Blog] #{p.full_name} wrote on your blog", response.subject
    assert_equal [pr.email], response.to
  end
  
  def test_comment_send_on_profile
    c = comments(:first)
    pr = profiles(:user)
    p = profiles(:user2)
    response = ArNotifier.deliver_comment_send_on_profile(c, pr, p)
    assert_equal "[#{SITE_NAME} Wall] #{p.full_name} wrote on your wall", response.subject
    assert_equal [pr.email], response.to
  end
  
  def test_feedback_mail
    f = feedbacks(:feedback1)
    r_c = Profile.admin_emails
    response = ArNotifier.deliver_feedback_mail(f, r_c)
    assert_equal "[#{SITE_NAME} Feedback] #{f.subject}", response.subject
    assert_equal ADMIN_RECIPIENTS, response.to
    assert_equal r_c, response.cc
  end
  
  def test_follow
    invtr = users(:user)
    invtd = users(:user2)
    d = "description"
    response = ArNotifier.deliver_follow(invtr, invtd, d)
    assert_equal "[#{SITE_NAME} Notice] #{invtr.full_name} is now following you", response.subject
    assert_equal [invtd.email], response.to
  end
  
  def test_delete_friend
    u = users(:user)
    u = users(:user2)
    response = ArNotifier.deliver_delete_friend(u, u)
    assert_equal "[#{SITE_NAME} Notice] Delete friend notice", response.subject
    assert_equal [u.email], response.to
  end
  
  def test_invite_friend
    s = student_checks(:student1)
    response = ArNotifier.deliver_invite(s)
    assert_equal "Hi #{s.full_name}, Get back to the future with #{SITE_NAME} on http://#{SITE}", response.subject
    assert_equal s.emails, response.to
    
  end
end