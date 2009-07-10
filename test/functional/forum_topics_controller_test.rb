require File.dirname(__FILE__) + '/../test_helper'

class ForumTopicsControllerTest < ActionController::TestCase
  include ForumsTestHelper
  ##
  # :show

  should "get show as :user" do
    assert_nothing_raised do
      get :show, {:forum_id => forum_topics(:one).forum.id, :id => forum_topics(:one)}, {:user => profiles(:user).id}
      assert_response 200
      assert_template 'show'
    end
  end

  should "get show as :admin" do
    assert_nothing_raised do
      get :show, {:forum_id => forum_topics(:one).forum.id, :id => forum_topics(:one)}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'show'
    end
  end

  ##
  # :new

  should "get new for :user" do
    assert_nothing_raised do
      get :new, {:forum_id => forum_topics(:one).forum.id}, {:user => profiles(:user).id}
      assert_response 200
      assert_template 'new'
    end
  end

  should "get new for :admin" do
    assert_nothing_raised do
      get :new, {:forum_id => forum_topics(:one).forum.id}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'new'
    end
  end

  ##
  # create

  should "create a new forum topic for :user" do
    assert_nothing_raised do
      assert_difference "ForumTopic.count" do
        post :create, {:forum_id => forums(:one).id, 
          :forum_topic => valid_forum_topic_attributes}, {:user => profiles(:user).id}
        assert_redirected_to forum_path(assigns(:topic).forum)
      end
    end
  end

  should "create a new forum topic for :admin" do
    assert_nothing_raised do
      assert_difference "ForumTopic.count" do
        post :create, {:forum_id => forums(:one).id,
          :forum_topic => valid_forum_topic_attributes}, {:user => profiles(:admin).id}
        assert_redirected_to forum_path(assigns(:topic).forum)
      end
    end
  end

  ##
  # :edit


  should "not get edit for :user" do
    assert_nothing_raised do
      get :edit, {:forum_id => forum_topics(:one).forum.id, :id => forum_topics(:one).id}, {:user => profiles(:user).id}
      assert_response 302
      assert flash[:error]
    end
  end

  should "get edit for :admin" do
    assert_nothing_raised do
      get :edit, {:forum_id => forum_topics(:one).forum.id, :id => forum_topics(:one).id}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'edit'
    end
  end

  ##
  # :update

  should "not update a forum topic for :user" do
    assert_nothing_raised do
      put :update, {:forum_id => forum_topics(:one).forum.id, 
        :id => forum_topics(:one).id,
        :forum => valid_forum_attributes}, {:user => profiles(:user).id}
      assert_response 302
      assert flash[:error]
    end
  end

  should "update a forum topic for :admin" do
    assert_nothing_raised do
      put :update, {:forum_id => forum_topics(:one).forum.id,
        :id => forum_topics(:one).id,
        :forum => valid_forum_attributes}, {:user => profiles(:admin).id}
      assert_redirected_to :controller => 'forums', :action => 'show', :id => forum_topics(:one).forum.to_param
    end
  end

  ##
  # :destroy

  should "not destroy a forum topic for :user" do
    assert_nothing_raised do
      assert_no_difference "ForumTopic.count" do
        delete :destroy, {:forum_id => forum_topics(:one).forum.id, 
          :id => forum_topics(:one).id}, {:user => profiles(:user).id}
        assert_response 302
        assert flash[:error]
      end
    end
  end

  should "destroy a forum topic for :admin" do
    assert_nothing_raised do
      assert_difference "ForumTopic.count", -1 do
        delete :destroy, {:forum_id => forum_topics(:one).forum.id, 
          :id => forum_topics(:one).id}, {:user => profiles(:admin).id}
        assert_redirected_to :controller => 'forums', :action => 'show', :id => forum_topics(:one).forum.to_param
      end
    end
  end
  
  ##
  # :index (old tests)
    
  should "get the index as :user" do
    assert_nothing_raised do
      get :index, {:forum_id => forum_topics(:one).forum.id}, {:user => profiles(:user).id}
      assert_response 302
    end
  end
  
  should "get the index as :admin" do
    assert_nothing_raised do
      get :index, {:forum_id => forum_topics(:one).forum.id}, {:user => profiles(:admin).id}
      assert_response 302
    end
  end

end
