require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  VALID_USER = {:password=>'123456', 
    :password_confirmation=>'123456', 
    :login=>'valid_user', 
    :profile_attributes => {:email=>'valid_user@example.com', 
    :group => '2006',
    :first_name => 'Rashmi', 
    :last_name => 'Yadav', 
    :gender => 'Female'},
    :terms_of_service => '1'}

  context 'A User instance' do
    should_require_attributes :login, :password
    should_require_unique_attributes :login

    should_ensure_length_in_range :login, 3..40
    should_ensure_length_in_range :password, 4..40
    should_protect_attributes :is_admin, :can_send_messages

    should 'be able to change their password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert u2.change_password('test', 'asdfg', 'asdfg')
      assert u2.valid?
      assert_not_equal(p, u2.crypted_password)
    end
    
    should 'require no spaces between password in order to change password' do
      u = User.find(users(:user).id)
      assert !u.change_password('te st', 'as dfg', 'as dfg')
    end
    
    should 'require the correct length of password in order to change password' do
      u = User.find(users(:user).id)
      assert !u.change_password('tes', 'asdfg', 'asdfg')
    end

    should 'require the correct current password in order to change password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert !u2.change_password('tedst', 'asdfg', 'asdfg')
      assert u2.valid?
      assert_equal(p, u2.crypted_password)
    end

    should 'require a matching password confirmation to change password' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert !u2.change_password('test', 'asdfg', 'asdfgd')
      assert u2.valid?
      assert_equal(p, u2.crypted_password)
    end

    should 'require password length at least four' do
      assert p = users(:user).crypted_password
      assert u2 = User.find(users(:user).id)
      assert !u2.change_password('test', 'asd', 'asd')
      assert !u2.valid?
    end

    
    should 'reset password if forgotten' do
      p1 = users(:user).crypted_password
      assert users(:user).forgot_password!
      assert_not_equal p1, users(:user).reload.crypted_password
    end

    should 'leave profile intact after a destroy' do
      u = users(:user)
      assert_no_difference "Profile.count" do
        assert_difference "User.count", -1 do
          u.destroy
        end
      end
    end
  end


  context 'A new User instance' do
    should 'be valid if the password and password confirmation matches' do
      assert u = User.new(VALID_USER)
      assert u.valid?
    end

    should 'be invalid if password confirmation does not match the password' do
      assert u = User.new(VALID_USER.merge(:password => '12345'))
      assert !u.valid?
    end

    should 'not be able to create without login' do
      assert_no_difference "User.count" do
        User.create({
            :email => 'test@test.com',
            :password => 'test',
            :password_confirmation => 'test',
            :terms_of_service => '1'     
          })
      end
    end
    
    should 'not be created without terms' do
      assert_no_difference "User.count" do
        User.create({
            :login => 'lquire',
            :email => 'lquire@example.com',
            :password => 'lquire',
            :password_confirmation => 'lquire',
            :terms_of_service => '0'
          })
      end
    end

    should 'be created when given valid options' do
      assert_difference "User.count" do
        ActionMailer::Base.default_url_options[:host] = 'localhost:9000'
        assert u = User.create(VALID_USER)
        assert !u.new_record?, u.errors.full_messages.to_sentence
        assert u.profile
        
      end
    end
  end

  context 'users(:user)' do
    should 'be able to reset their password' do
      users(:user).update_attributes(:password => 'new password', :password_confirmation => 'new password')
      assert_equal users(:user), User.authenticate('user', 'new password')
    end

    should 'not rehash their password' do
      users(:user).update_attributes(:login => 'aruna')
      assert_equal users(:user), User.authenticate('aruna', 'test')
    end

    should 'be able to authenticate' do
      assert_equal users(:user), User.authenticate('user', 'test')
    end

    should 'be remembered' do
      users(:user).remember_me!
      assert users(:user).remember_token?
      assert_not_nil users(:user).remember_token
      assert_not_nil users(:user).remember_token_expires_at
    end
  end
  #
  #   def test_should_not_authenticate_user_inactive
  #     assert !User.authenticate('inactive', 'test')
  #   end
  #
  #
  #
  #
  #   def test_full_name
  #     assert u = users(:system)
  #     assert_equal "system", u.full_name
  #
  #     assert u2 = users(:second)
  #     assert_equal 'hello', u2.full_name
  #
  #     assert u3 = users(:quentin)
  #     assert_equal "quentin", u3.full_name
  #   end
  #
  #
  #
  should "not be able to mail" do
    assert !users(:inactive).can_mail?( users(:user))
    assert users(:user).can_mail?( users(:inactive))
    assert !users(:cant_message).can_mail?( users(:user))
    assert users(:user).can_mail?( users(:cant_message))
  end
    
  should "be active" do
    u = users(:user)
    assert u.profile.activate!
  end
  
  should " email should be confirmed" do
    u = users(:user)
    assert !u.email_confirmed?
  end
  
  should "last login date" do
    assert_equal Date.today, users(:user).record_login!
  end
  
  should " have reference" do
    u = users(:user)
    assert_not_nil u.matched_referrers
  end
  
  context "should request new email" do
    should " have invaild new email" do
      p = users(:user)
      assert !p.request_email_change!('rays')
    end
    
    should " have blank email" do
      p = users(:user)
      assert !p.request_email_change!('')
    end
    
    should "request new email" do
      p = users(:user)
      assert p.request_email_change!('rays.rashmi@gmail.com')
    end
  end
  
  should 'test full name' do
    u = users(:user)
    assert_not_nil u.full_name
    assert_equal "De Veloper", u.full_name
    assert_not_equal 'De', u.full_name
  end
  
  should 'test full name if first name is nil' do
    u = users(:user5)
    assert_not_nil u.full_name
    assert_equal 'Saxena', u.full_name
  end
  
  should 'test full name if invalid first name or last name' do
    u = users(:user6)
    assert_not_nil u.full_name
  end
    
  #
  #   def test_associations
  #     _test_associations
  #   end
end
