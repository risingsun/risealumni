require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase

  VALID_USER = {
    :login => 'lquire',
    :email => 'lquire@example.com',
    :password => 'lquire', :password_confirmation => 'lquire',
    :terms_of_service=>'1', :first_name => 'Rashmi', :last_name => 'Yadav', :group => '2003'
  }

  def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'A visitor' do
    should 'be able to signup(exist in the database)' do
      assert_difference "User.count" do
        xhr :post, :signup, {:user => {:login => 'rashmi123',:password => 'test', :password_confirmation => 'test', 
            :profile_attributes => {:email => 'rays.yadav@gmail.com',  
              :first_name => 'Rohit', 
              :last_name => 'Yadav', 
              :group => '1997', 
              :gender => 'Male'} , :terms_of_service => '1'
          }}
        assert assigns['user']
        assert_template '_thanks'
        assert_response :success
        #do_assertion
        #do_login_assertion
      end
    end
    

    should "be signup (not in database but provides refferals name " do
      assert_difference "User.count" do
        xhr :post, :signup, {:user => {:login => 'rashmiy',:password => 'test', :password_confirmation => 'test', 
            :profile_attributes => {:email => 'ras123.yaadv@gmail.com',  
              :first_name => 'rays', 
              :last_name => 'jain', 
              :group => '2006', 
              :gender => 'Female'}, :terms_of_service => '1',:first_referral_person_name => 'Rashmi Yadav',:first_referral_person_year => '2006',
            :second_referral_person_name => 'John Jones', :second_referral_person_year => '2005', 
            :third_referral_person_name => 'De Veloper', :third_referral_person_year => '2006'
          }}
        assert assigns['user']
        assert_template '_thanks'
        assert_response :success
      end
    end

    should "not be sign up(not in database and also not provides refferals name)" do
      assert_no_difference "User.count" do
        post :signup, {:user => {:login => 'rashmiy',:password => 'test', :password_confirmation => 'test', 
             :profile_attributes => {:email => 'ras.yaadv@gmail.com',  
             :first_name => 'Rims', 
             :last_name => 'Jain', 
             :group => '2006', 
             :gender => 'Female'}, :terms_of_service => '1'}}
        #assert_nil assigns['user']
        assert_template 'signup'
        #assert_equal 'Thanks for signing up. Please check your email for a confirmation message from us.', flash[:notice]
      end
    end


    should "signup if profile already exists but email not verified" do
      post :signup, {:user => {:login => 'poojag',:password => 'test', 
           :password_confirmation => 'test', :terms_of_service=>'1',
           :profile_attributes => {:email => 'user3@example.com', 
           :first_name => 'rashmi', :last_name => 'yadav', 
           :group => '2006', :gender => 'Female'} }}
      #assert_response :redirect
      assert assigns['user']
      assert_template 'signup'
      #do_assertion
      #assert_equal 'Thanks for signing up. Please check your email for a confirmation message from us.', flash[:notice]
    end
    

  
    should "signup if profile already exists but email not verified and in database" do
      xhr :post, :signup, {:user => {:login => 'anurag', :password => 'test',
          :password_confirmation => 'test', :terms_of_service => '1',
          :profile_attributes => {:email => 'user3@example.com',
          :first_name => 'Rashmi', :last_name => 'Yadav',
          :group => '2006', :gender => 'Female'} }}
      assert assigns['user']
      assert_template '_thanks'
    end
    
    should "signup if profile already exists but email not verified and in database and taking another email" do
      xhr :post, :signup, {:user => {:login => 'anurag', :password => 'test',
          :password_confirmation => 'test', :terms_of_service => '1',
          :profile_attributes => {:email => 'user4@example.com',
          :first_name => 'Rashmi', :last_name => 'Yadav',
          :group => '2006', :gender => 'Female'} }}
      assert assigns['user']
      assert_template '_thanks'
    end
  
    should "signup if profile already exists but email not verified and not in database and provides referral name" do
      xhr :post, :signup, {:user => {:login => 'anu', :password => 'test',
          :password_confirmation => 'test', :terms_of_service => '1',
          :profile_attributes => {:email => 'user4@example.com',
          :first_name => 'John', :last_name => 'Abraham',
          :group => '2005', :gender => 'Male'}, :terms_of_service => '1',:first_referral_person_name => 'Rashmi Yadav',:first_referral_person_year => '2006',
          :second_referral_person_name => 'John Jones', :second_referral_person_year => '2005', 
          :third_referral_person_name => 'De Veloper', :third_referral_person_year => '2006' }}
      assert assigns['user']
      assert_template '_thanks'
    end
    
    should "signup if profile already exists but email not verified and not in database and not providing referral  names" do
      xhr :post, :signup, {:user => {:login => 'anu', :password => 'test',
          :password_confirmation => 'test', :terms_of_service => '1',
          :profile_attributes => {:email => 'user4@example.com',
          :first_name => 'John', :last_name => 'Abraham',
          :group => '2005', :gender => 'Male'} }}
      assert assigns['user']
      assert_template '_thanks'
    end

    should "not signup if profile already exists and but email not verified (password confirmation is blank )" do
      assert_no_difference "User.count" do
        post :signup, {:user => {:login => 'poojag',:password => 'test', :password_confirmation => '', :terms_of_service=>'1',
             :profile_attributes => {:email => 'user123@example.com', :first_name => 'john', :last_name => 'jones', :group => '2005', :gender => 'Female'} }}
        assert assigns['user']
        assert_template 'signup'
        #do_sign_up_assertion          #tag checking
      end
      
    end
    
    should "not sign up if profile already exists and email verified" do
      assert_no_difference "User.count" do
        post :signup, {:user => {:login => 'user123',:password => 'test', :password_confirmation => 'test', 
             :profile_attributes => {:email => 'user@example.com', :first_name => 'De', :last_name => 'Veloper', :group => '2006'}, :terms_of_service=>'1'}}
        assert_nil assigns(:u)
        assert_template 'signup'
        #do_sign_up_assertion
      end
    end
    
    should "require login on signup" do
      assert_no_difference "User.count" do
        create_user(:login => nil)
        assert_nil assigns(:u)
        assert_response :success
      end
    end
    
    should" require password on signup" do
      assert_no_difference "User.count" do
        create_user(:password => nil)
        assert_nil assigns(:u)
        assert_response :success
      end
    end
    
    should "require email on signup" do
      assert_no_difference "User.count" do
        create_user(:profile_attributes => {:email => nil})
        assert_nil assigns(:u)
        assert_response :success
      end
    end
    
    should "not signup bcoz no terms" do
      flashback
      assert_no_difference "User.count" do
        post :signup, {
          :user => {
            :login => 'lquire',
            :email => 'lquire@example.com',
            :password => 'lquire',
            :password_confirmation => 'lquire',
            :terms_of_service => '0'
          }
        }
      end
      assert_response :success
      assert_nil assigns(:u)
      
    end    
  end

  def test_should_login_and_redirect
    post :login, :user=>{:login => 'user', :password => 'test'}
    assert session[:user]
    assert assigns['u']
    assert_redirected_to profile_path(assigns['u'].profile)
  end

  def test_should_fail_login_and_not_redirect
    post :login, :user => {:login => 'user', :password => 'bad password'}
    assert_nil session[:user]
    assert_response :success
  end
  
  def test_should_not_login_if_email_not_varified
    @request.session[:user] = profiles(:inactive)
    post :login, :user => {:login => users(:inactive).login, :password => 'test'}
    assert_equal 'Your email address has not yet been confirmed.', flash[:error]
    assert_response 302
  end
  
  def test_should_not_login_with_blank_login
    post :login, :user=> {:login => '',:password => 'test'}
    assert_nil session[:user]
    assert_nil assigns['u']
  end
  
  def test_should_not_login_with_blank_password
    post :login, :user=> {:login => 'user',:password => ''}
    assert_nil session[:user]
    assert_nil assigns['u']
  end

  
  context " on:POST forgot password" do
    should " raise error if email not exists" do
      flashback
      post :login, :profile => {:email=>'asdf'}, :new_password => 'New Password'
      assert_nil session[:user]
      assert_response :success
      assert_equal nil, flash[:notice]
      assert_equal "Could not find that email address. Try again.", flash.flashed[:error]
      assert_template 'forgot_password'
      do_forgot_password_assertion              #tag checking
    end
    
    should " get forgot password " do
      flashback
      assert u = users(:user)
      assert p = u.crypted_password
      post :login, :profile => {:email => profiles(:user).email}, :commit =>  'New Password'
      assert_response :success
      #assert_equal "A new password has been mailed to you.", flash.now[:notice]
      assert_not_equal(assigns(:p), u.crypted_password)
      assert_template 'login'
      do_login_assertion                         #tag checking
    end
    
    should "not send mail for password no email provided" do
      post :login, :profile => {:email => ''}, :new_password => 'New Password'
      assert_nil assigns['u']
      assert_template  'forgot_password'
      do_forgot_password_assertion               #tag checking
    end
  end
  
  def test_should_logout
    login_as :user
    get :logout
    assert_nil session[:user]
    assert_redirected_to home_url
  end

  def test_should_remember_me
    post :login, :user=>{:login => 'user', :password => 'test', :remember_me => "1"}
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :user=>{:login => 'quentin', :password => 'test', :remember_me => "0"}
    assert_nil @response.cookies["auth_token"]
  end

  def test_should_delete_token_on_logout
    login_as :user
    get :logout
    assert_equal nil, @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    users(:user).remember_me!
    @request.cookies["auth_token"] = cookie_for(:user)
    get :login
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:user).remember_me!
    users(:user).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies["auth_token"] = cookie_for(:user)
    get :login
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:user).remember_me!
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :login
    assert !@controller.send(:logged_in?)
  end
  
  def test_of_confirmed_user
    u = users(:user)
    get :confirmation_email, :user_id => u, :hash => u.email_verification 
    assert_redirected_to login_path
  end
  
  def test_should_confirm_email
    u = users(:user2)
    get :confirmation_email, :user_id => u, :hash => u.email_verification 
    assert_redirected_to login_path
  end
  
  def test_should_not_confirm_email
    u = users(:user2)
    get :confirmation_email, :user_id => u, :hash => '43442424234ff'
    assert_equal "We're sorry but it seems that the confirmation did not go thru. You may have provided an expired key.", flash[:notice]
    assert_redirected_to login_path
  end
  
  context " should check email availability" do
    
    should "email exists" do
      get :check_email, :email => 'user@example.com'
      assert_response :success
    end
    
    should "email does not exists" do
      get :check_email, :email => 'lquire@example.com'
      assert_response :success
    end
  end
  
  context " should check login availability" do
    
    should "login exists" do
      get :check_login, :login => 'user'
      assert_response :success
    end
    
    should "login does not exists" do
      get :check_login, :login => 'lquire'
      assert_response :success
    end
    
  end
  
  protected
  def create_user(options = {}, signup_code = '1234')
    post :signup, {:user => { :login => 'lquire', :password => 'lquire', :password_confirmation => 'lquire', :terms_of_service => '1',  
        :profile_attributes => {:email => 'lquire@example.com', :first_name => 'Rashmi', :last_name => 'Yadav', :group => '2003'} }.merge(options)}
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).remember_token
  end
=begin  
  def do_sign_up_assertion
    assert_tag :tag => 'form'
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[login]'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :name => 'user[password]'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :name => 'user[password_confirmation]'}
   
    
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][email]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][first_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][middle_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][last_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][maiden_name]', :title => 'Name before marriage'}
    assert_tag :tag => 'select', :attributes => {:name => 'user[profile_attributes][gender]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[profile_attributes][year]', :title => 'Year in which you would have given your 12th boards.'}

    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[first_referral_person_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[first_referral_person_year]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[second_referral_person_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[second_referral_person_year]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[third_referral_person_name]'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[third_referral_person_year]'}
    
    assert_tag :tag => 'input', :attributes => {:type => 'checkbox', :name => 'user[terms_of_service]'}
    assert_tag :tag => 'a', :attributes => {:href => '/tos'}
    assert_tag :tag => 'input', :attributes => {:type => 'submit', :value => 'Sign Me Up'}
  
    
    
  end
=end 
  
  def do_assertion
    assert_tag :tag => "div", :attributes => {:class => "widget_large"}
    #assert_tag :tag => 'img',:attributes => {:title => 'Help', :class => 'help'},  :parent => {:tag => 'h2', :attributes => {:class => 'widget_lrg_top'}, :content => "Thanks for signing up!"}
    #assert_tag :tag => 'img', :attributes => {:alt => 'Help', :class => 'help'}
    #assert_tag :tag => 'div', :content => "Please click on the confirmation link sent to"
  end

  def do_forgot_password_assertion
    assert_tag :tag => 'form',:attributes => {:action => login_path}
    assert_tag :tag => 'img',:attributes => {:title => 'Help', :class => 'help'}
    assert_tag :tag => 'p', :content => 'A new password will be generated and sent to this email address.'
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'profile[email]'}
    assert_tag :tag => 'button', :attributes => {:type => 'submit'}
  end
  
  def do_login_assertion
    assert_tag :tag => 'form',:attributes => {:action => login_path}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[login]'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :name => 'user[password]'}
    assert_tag :tag => 'input', :attributes => {:type => 'checkbox', :name => 'user[remember_me]'}
    assert_tag :tag => 'img', :attributes => {:alt => 'Login'}
  end
  
end
