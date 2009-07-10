require File.dirname(__FILE__) + '/../test_helper'

class InvitationTest < ActiveSupport::TestCase
 
  should_belong_to :profile
  should_require_attributes :email, :profile
  should_require_unique_attributes :email, :scoped_to => :profile_id
  should_allow_values_for :email, 'anuy@ahoo.com', 'anuraag.jpr@gmail.com',
                          :message => 'does not look valid.<br/>'
  should_not_allow_values_for :email, 'anurag.com', '@yahoo.com', 'abc@def', 
                              :message => 'does not look valid.<br/>' 

  should 'test if email dose not exists in profile' do
    ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
    p = profiles(:user2)
    i = Invitation.new(:profile_id => p.id, :email => 'ddddd@gmail.com')
    i.save
    assert_equal :new, i.status    
  end
  
  should 'test if email exists in profile' do
    ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
    p = profiles(:user)
    i = Invitation.new(:profile_id => p.id, :email => 'anuraag.jpr@gmail.com')
    i.save
    assert_equal :already_existing, i.status
  end

  should 'test recent days' do
    ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
    p = profiles(:user)
    i = invitations(:three)
    assert_equal true, i.recent?(7)
  end    
  
  should 'test send invitation' do
    ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
    p = profiles(:user)
    i = Invitation.create(:profile_id => p.id, :email => 'xyz@gmail.com')
    response = ArNotifier.deliver_invite_batchmates(i)
    assert_equal "[#{SITE_NAME} Invitation] Your batch mates are looking for you!", response.subject
    assert_equal [i.email], response.to   
  end 
 
end
