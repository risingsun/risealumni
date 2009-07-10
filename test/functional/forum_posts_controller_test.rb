require File.dirname(__FILE__) + '/../test_helper'

class ForumPostsControllerTest < ActionController::TestCase
  include ForumsTestHelper
  
  ##
  # :new
  
  should "not respond to new" do
    assert !ForumPostsController.new.respond_to?(:new)
  end
  
  ##
  # create

  should "create a new forum post for :user" do
    assert_nothing_raised do
      assert_difference "ForumPost.count" do
        post :create, {:forum_id => forum_topics(:one).forum.id, 
                       :topic_id => forum_topics(:one).id,
                       :forum_post => valid_forum_post_attributes}, {:user => profiles(:user).id}
        assert_redirected_to forum_topic_path(assigns(:forum),assigns(:topic))
      end
    end
  end

  should "create a new forum post for :admin" do
    assert_nothing_raised do
      assert_difference "ForumPost.count" do
        post :create, {:forum_id => forum_topics(:one).forum.id, 
                       :topic_id => forum_topics(:one).id,
                       :forum_post => valid_forum_post_attributes}, {:user => profiles(:admin).id}
        assert_redirected_to forum_topic_path(assigns(:forum),assigns(:topic))
      end
    end
  end
  
  
  should "create a new forum post for :admin, xml" do
    assert_nothing_raised do
      assert_difference "ForumPost.count" do
        post :create, {:format=>'xml', :forum_id => forum_topics(:one).forum.id, 
                       :topic_id => forum_topics(:one).id,
                       :forum_post => valid_forum_post_attributes}, {:user => profiles(:admin).id}
         assert_response 200
      end
    end
  end
    
  ##
  # :destroy
  
  should "destroy a forum post for :user" do
    assert_nothing_raised do
      assert_difference "ForumPost.count", -1 do
        delete :destroy, {:forum_id => forum_posts(:one).topic.forum.id, 
                          :topic_id => forum_posts(:one).topic.id,
                          :id => forum_posts(:one).id}, {:user => profiles(:user).id}
        assert_redirected_to forum_topic_path(assigns(:forum),assigns(:topic))
      end
    end
  end

  should "destroy a forum post for :admin" do
    assert_nothing_raised do
      assert_difference "ForumPost.count", -1 do
        delete :destroy, {:forum_id => forum_posts(:one).topic.forum.id, 
                          :topic_id => forum_posts(:one).topic.id,
                          :id => forum_posts(:one).id}, {:user => profiles(:admin).id}
        assert_redirected_to forum_topic_path(assigns(:forum),assigns(:topic))
      end
    end
  end
  
  should "destroy a forum post for :admin js" do
    assert_nothing_raised do
      assert_difference "ForumPost.count", -1 do
        delete :destroy, {:format=>'js', :forum_id => forum_posts(:one).topic.forum.id, 
                          :topic_id => forum_posts(:one).topic.id,
                          :id => forum_posts(:one).id}, {:user => profiles(:admin).id}
          assert_response 200
      end
    end
  end
  
end

