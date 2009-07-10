require File.dirname(__FILE__) + '/../test_helper'

class ProfilesControllerTest < ActionController::TestCase
  
  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #@login      = logins(:quentin)
  end


  context 'on POST to :search' do
    setup do
      post :search, {:q => 'user'}, {:user => profiles(:user)}
    end

    should_assign_to :results
    should_respond_with :success
    should_render_template 'shared/user_friends'
  end
  
  context 'on GET to :index' do
    setup do
      get :index, {:q => 'user'}, {:user => profiles(:user)}
    end

    should_assign_to :results
    should_assign_to :p
    should_respond_with :success
    should_render_template 'shared/user_friends'
  end

  context 'on GET to :show while not logged in' do
    setup do
      get :show, {:id => profiles(:user).id}
    end

    should_not_assign_to :user
    should_not_assign_to :profile
    
  end

  context 'on GET to :show.rss ' do
    setup do
      get :show, {:id => profiles(:user).id, :format=>'rss'}, :user => users(:user)
      assert_match "<rss version=\"2.0\">\n  <channel>\n    <title>#{SITE_NAME} Activity Feed</title>", @response.body
    end

    should_assign_to :user
    should_assign_to :profile
  end

  context 'on GET to :edit while not logged in' do
    setup do
      get :edit, {:id => profiles(:user).id}
    end

    should_not_assign_to :user
    should_not_assign_to :profile
    should_respond_with :redirect
    should_redirect_to 'login_path'
    should_not_set_the_flash
  end


  context 'on GET to :show while logged in' do
    setup do
      get :show, {:id => profiles(:user).id}, {:user => profiles(:user).id}
      
      assert_tag :tag => 'a', :content => 'Edit Profile', :attributes => {:href => edit_profile_path(assigns(:profile))}
      assert_tag :tag => 'a', :content => 'Edit Account',:attributes => {:href => edit_account_profile_path(assigns(:profile))}
      #assert_no_tag :tag => 'a', :content => 'Direct Message'
      #assert_tag :tag => 'a', :content => 'Read My Blogs'
      #assert_no_tag :tag => 'a', :content => 'Our Wall-to-Wall'
      do_show_assertion
    end

    should_assign_to :user
    should_assign_to :profile
    should_assign_to :video
    should_respond_with :success
    should_render_template :show
    
    should_not_set_the_flash
  end
  
  
  context 'on GET to :edit while logged in' do
    setup do
      get :edit, {:id => profiles(:user).id}, {:user => profiles(:user).id}
    end

    should_assign_to :user
    should_assign_to :profile
    should_respond_with :success
    should_render_template :edit
    should_render_a_form
    should_not_set_the_flash
  end 

  context 'on GET to : show while both youtube_username & flickr is blank'   do
    setup do
      get :show, {:id => profiles(:user2).id}, {:user => profiles(:user2).id}
      do_show_assertion
    end
  
    should_assign_to :user
    should_assign_to :profile
    should_not_assign_to :video
    should_render_template :show 
    
  end
  
  context ' on GET to : show while logged in as user2' do
    setup do
      get :show, {:id => profiles(:user2).id}, {:user => profiles(:user).id}
      assert_tag :tag => 'a', :content => 'Edit Profile' 
      assert_tag :tag => 'a', :content => 'Direct Message', :attributes => {:href => direct_message_profile_messages_path(assigns(:profile))} 
      assert_tag :tag => 'a', :content => 'Read My Blogs', :attributes => {:href => profile_blogs_path(assigns(:profile))} 
      assert_tag :tag => 'a', :content => 'Our Wall-to-Wall', 
                 :attributes => {:href => profile_comments_path(assigns(:profile))}  if profiles(:user).has_wall_with(profiles(:user2))
      
      do_not_show_blogs
      do_show_assertion
      do_not_show_login_assertion
      do_not_show_work_info
      
    end
    
    should_assign_to :user
    should_assign_to :profile
    should_render_template :show
  end
 

  context 'rendering an avatar' do  

    should 'use the user\'s icon if it exists' do
      p =  profiles(:user)
      p.icon = File.new(File.join(RAILS_ROOT, ['test', 'public','images','user.png']))
      p.save!
      #raise (p.send :icon_state).inspect
      assert_not_nil p.icon
      get :show, {:id => p.id}, {:user => p.id}
      assert_tag :img, :attributes => { :src => /\/system\/profiles\/icons\/\d*\/big\/user.png/ }
    end

    should 'send the app\'s internal default as the default to gravatar' do
      p =  profiles(:user2)
      assert_nil p.icon_file_name
      get :show, {:id => p.id}, {:user => p.id, :public_view => true}
      #assert_tag :img, :attributes => { :src => /http...www.gravatar.com\/avatar\/[0-9a-f]+\?size\=50&amp;default\=http...test\.host\/images\/avatar_default_small\.png/ }
    end
    
    should 'use gravatar otherwise' do
      p =  profiles(:user2)
      assert_nil p.icon_file_name
      get :show, {:id => p.id}, {:user => p.id, :public_view => true}
      assert_tag :img, :attributes => {:src => /www\.gravatar\.com/}
  end
  end

  context 'on POST to :delete_icon' do
    should 'delete the icon from the users profile' do
      assert_not_nil profiles(:user).icon_file_name
      post :delete_icon, {:id => profiles(:user).id, :format => 'js'}, {:user => profiles(:user).id}
      assert_response :success
      assert_nil assigns(:p).reload.icon_file_name
    end
  end


  context 'on POST to :update' do
    
    should 'update a user\'s profile with good data when logged in' do
      assert_equal 'De', profiles(:user).first_name

      post :update, {:id => profiles(:user).id, :user => {:email => 'user@example.com'}, :profile => {:first_name => 'Bob'}, :switch => 'name'}, {:user => profiles(:user).id}

      assert_response :redirect
      assert_redirected_to edit_profile_path(profiles(:user).reload)
      assert_equal 'Settings have been saved.', flash[:notice]

      assert_equal 'Bob', profiles(:user).reload.first_name
    end

    should 'not update a user\'s profile with bad data when logged in' do
      put :update, {:id => profiles(:user).id, :profile => {:email => ''}, :switch => 'name'}, {:user => profiles(:user).id}

      assert_response :success
      assert_template 'edit'
      assert_not_nil assigns(:profile).errors
      do_edit_assertion
    end

    should 'not update a user\'s profile without a switch' do
      assert_equal 'De', profiles(:user).first_name
      put :update, {:id => profiles(:user).id, :user => {:email => 'user@example.com'}, :profile => {:first_name => 'Bob'}}, {:user => profiles(:user).id}
      assert_equal 'De', profiles(:user).first_name
      assert_response :success
    end
    
    should' not update a user\'s profile with unsupported switch' do
      assert_equal 'De', profiles(:user).first_name
      put :update, {:id => profiles(:user).id, :user => {:email => 'user@example.com'},:switch => 'education', :profile => {:first_name => 'Bob'}}, {:user => profiles(:user).id}
      assert_response :success
    end

    should 'update a user\'s password with good data when logged in' do
      pass = users(:user).crypted_password
      put :update, {:id => profiles(:user).id, :verify_password => 'test', :new_password => '1234', :confirm_password => '1234', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :redirect
      assert assigns(:p)
      assert_equal "Password has been changed.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
      assert_not_equal pass, assigns(:u).reload.crypted_password
    end

    should 'not update a user\'s password with bad data when logged in' do
      pass = users(:user).crypted_password
      put :update, {:id => profiles(:user).id, :verify_password => 'test', :new_password => '4321', :confirm_password => '1234', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :success
      assert_template 'edit_account'
      assert_not_nil assigns(:user).errors
      #do_edit_account_assertion                 #tag checking
    end
    
    should 'not update a user\'s password when not providing verify_password' do
      pass = users(:user).crypted_password
      put :update, {:id => profiles(:user).id, :verify_password => '', :new_password => '4321', :confirm_password => '1234', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :success
      assert_template 'edit_account'
      assert_not_nil assigns(:user).errors
      #do_edit_account_assertion                #tag checking
    end
    
    should 'not update a user\'s password when not providing new_password' do
      pass = users(:user).crypted_password
      put :update, {:id => profiles(:user).id, :verify_password => 'test', :new_password => '', :confirm_password => '1234', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :success
      assert_template 'edit_account'
      assert_not_nil assigns(:user).errors
      #do_edit_account_assertion
    end
    
    should 'not update a user\'s password while verify password is wrong' do
      put :update, {:id => profiles(:user).id, :verify_password => 'rays', :new_password => '', :confirm_password => '1234', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :success
      assert_template 'edit_account'
      assert_not_nil assigns(:user).errors
      #do_edit_account_assertion
     
    end
    
    should 'update a user\'s password while verify password, new password and confirm password are same ' do
      put :update, {:id => profiles(:user).id, :verify_password => 'test', :new_password => 'test', :confirm_password => 'test', :switch => 'password'}, {:user => profiles(:user).id}
      assert_response :redirect
      assert assigns(:p)
      assert_equal "Password has been changed.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
    end
    
    should 'update a user\'s permission with good data when logged in' do
      put :update, {:id => profiles(:user).id, :switch => 'permissions'}, {:user => profiles(:user).id}
      assert_equal "Settings have been saved.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
      assert_not_nil assigns(:user).errors
    end
    
    
    should 'update a user\'s permission with bad data when logged in' do
      put :update, {:id => profiles(:user).id, :switch => 'permissions'}, {:user => profiles(:user).id}, :profile => 'aaa'
      assert_equal "Settings have been saved.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
      assert_not_nil assigns(:user).errors
    end
    
    should'update default permission'do
      put :update, {:id => profiles(:user).id, :switch => 'set_default_permissions'}, {:user => profiles(:user).id}
      assert_equal "Settings have been saved.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
      assert_not_nil assigns(:user).errors
    end
    
    should 'update a user\'s email with good data when logged in' do
      put :update, {:id => profiles(:user).id, :switch => 'request_email', :user => {:requested_new_email => 'rays.rashmi@gmail.com'}}, :user => profiles(:user)
      assert_equal "Email confirmation request has been sent to the new email address.", flash[:notice]
      assert_redirected_to edit_account_profile_path(profiles(:user))
      assert_not_nil assigns(:user).errors
    end
    
    should 'not update a user\'s email with bad data when logged in' do
      put :update, {:id => profiles(:user).id, :switch => 'request_email', :user => {:requested_new_email => ''}}, :user => profiles(:user)
      assert_template 'edit_account'
      assert_not_nil assigns(:user).errors
    end
   
  end
  
  should 'set status' do
    setup do
      @request.session[:user] = profles(:user).id
      post :status_update ,  :id => profiles(:user).id, :value => 'ssss'
      assert_response :success
    end
  end


  should "delete" do
    assert_difference 'User.count', -1 do
      assert users(:user)
      delete :destroy, {:id=>users(:user).id}, {:user, users(:user).id}
      assert_response 200
      assert_nil User.find_by_id(users(:user).id)
    end
  end
  
 
  context "should update new email " do

    should " confirm email & saved " do
      #@request.session[:user] = profiles(:user)
      put :update_email, :hash => users(:user).email_verification, :profile_id => profiles(:user).id
      assert_equal 'Your email has been updated', flash[:notice]
      assert_redirected_to home_path
    end
    should " not confirm email" do
      @request.session[:user] = profiles(:user)
      put :update_email, :profile_id => profiles(:user).id, :hash => '33333'
      assert_equal "We're sorry but it seems that the confirmation did not go thru. You may have provided an expired key.", flash[:notice]
      assert_redirected_to home_path
    end

    
   
    should " confirm email & but not saved " do   
      put :update_email, :profile_id => profiles(:user7).id, :user => users(:user7), :hash => users(:user7).email_verification
      assert_equal 'This email has already been taken', flash[:notice]
      assert_redirected_to home_path
    end
     
    
  end
  
  should "find batchmates" do
    get :batch_mates, {:id => profiles(:user).id, :page => 2, :per_page => 2}, :user => users(:user).id
    assert_not_nil assigns('results')
    assert_equal "Group Members", assigns['title']
    assert_template 'shared/user_friends'
  end
  
  context 'on GET :network' do
    
    should 'find network' do
      p = profiles(:user)
      get :network, {:id => p.id}, :user => users(:user).id
      assert_not_nil assigns(:profile)
      assert p.followers
      assert p.followings
      assert_template 'network'
    end
    
    should 'find network (while profile_id and user_id are different)' do
      p = profiles(:cant_message)
      get :network, {:id => p.id}, :user => users(:user2).id
      assert_not_nil assigns(:profile)
      assert_equal [], p.followers
      assert_equal [], p.followings
      assert_template 'network'
    end
    
    should 'not find network (while logged in user is inactive)' do
      get :network, {:id => profiles(:user).id}, :user => users(:inactive).id
      assert_nil assigns(:profile)
    end
    
  end
  
  should "find followers" do
    get :followers, {:id => profiles(:user).id, :page => 2, :per_page => 2}, :user => users(:user).id
    assert_not_nil assigns(:results)
    assert_equal "Followers", assigns(:title)
    assert_template 'shared/user_friends'
  end
  
  should "find followings" do
    get :followings, {:id => profiles(:user).id, :page => 2, :per_page => 2}, :user => users(:user).id
    assert_not_nil assigns(:results)
    assert_equal "Followings", assigns(:title)
    assert_template 'shared/user_friends'
  end
  
  should " find batch details" do
    get :batch_details, {:group => '2006', :page => 2, :per_page => 2}, :user => users(:user)
    assert_not_nil assigns(:students)
    assert_not_nil assigns(:profiles)
    assert_template 'batch_details'
  end
  
  should "not find batch details with invaild group" do
    get :batch_details, {:group => '200', :page => 2, :per_page => 2}, :user => users(:user)
    assert_nil assigns(:students)
    assert_nil assigns(:profiles)
    assert_equal "Group is invalid! Sorry, please enter a valid group", flash[:error]
    assert_redirected_to home_path
  end
  def test_edit_account
    @request.session[:user] = users(:user)
    get :edit_account, :id => profiles(:user).id
    assert_response :success
  end
  def test_status_update
    @request.session[:user] = users(:user)
    post :status_update, :id => profiles(:user).id,:value => 'Hey!!!!!!!!!!!!!!!!!!!!'
    assert_response :success
    assert_equal 'Hey!!!!!!!!!!!!!!!!!!!!',assigns(:profile).status_message
  end
  
  
  private
  
  def do_edit_account_assertion
    assert_tag :tag => 'form'
    assert_tag :tag => 'div', :attributes => {:id => 'change_passwords'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :class => 'text_field', :name => 'verify_password'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :class => 'text_field', :name => 'new_password'}
    assert_tag :tag => 'input', :attributes => {:type => 'password', :class => 'text_field', :name => 'confirm_password'}
    assert_tag :tag => 'img', :attributes => {:alt => 'Change-password'}
     
    assert_tag :tag => 'div', :attributes => {:id => 'change_email'}
    assert_tag :tag => 'input', :attributes => {:type => 'text', :class => 'text_field', :name => 'user[requested_new_email]'}
    assert_tag :tag => 'img', :attributes => {:alt => 'Change-email'}
    
    assert_tag :tag => 'div', :attributes => {:id => 'set_default_permission'}
    assert_tag :tag => 'select', :attributes => {:name => 'profile[default_permission]'}, :children => {:count => 3}
    assert_tag :tag => 'img', :attributes => {:alt => 'Set-default'}
    
    assert_tag :tag => 'input', :attributes => {:type => 'hidden', :name => 'switch', :value => 'set_default_permissions'}
    
  end
  
  def do_edit_assertion
    assert_tag :tag => 'form'
    assert_tag :tag => 'img', :attributes => {:alt => 'Update'}
    assert_tag :tag => 'input', :attributes => {:type => 'file'}
  end
  
  def do_show_assertion
    do_education_info_assertion  
  end
  
  
  def do_education_info_assertion
     assert_tag :tag => 'th', :content => 'From'
     assert_tag :tag => 'th', :content => 'To'
  end
  
  def do_not_show_login_assertion
    assert_no_tag :tag => 'form', :attributes => {:action => login_path}
    assert_no_tag :tag => 'input', :attributes => {:type => 'text', :name => 'user[login]'}
    assert_no_tag :tag => 'input', :attributes => {:type => 'password', :name => 'user[password]'}
    assert_no_tag :tag => 'input', :attributes => {:type => 'password', :name => 'user[password]'}
  end
  
  def do_not_show_blogs
    assert_no_tag :tag => 'strong', :content => 'Blog'
    assert_no_tag :tag => 'a', :attributes => {:href => assigns(:profile).blog}
  end
  
  def do_not_show_work_info
    assert_no_tag :tag => 'h3', :content => 'Company Name'
    assert_no_tag :tag => 'h3', :content => 'Industry'
  end
   



end
