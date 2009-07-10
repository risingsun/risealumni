require File.dirname(__FILE__) + '/../test_helper'

class ForumsControllerTest < ActionController::TestCase
  include ForumsTestHelper
  ##
  # :index

  should "get the index as :user" do
    assert_nothing_raised do
      get :index, {}, {:user => profiles(:user).id}
      assert_response 200
      assert_template 'index'
    end  
  end

  should "get the index as :admin" do
    assert_nothing_raised do
      get :index, {}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'index'
    end 
  end


  ##
  # :show

  should "get show as :user" do
    assert_nothing_raised do
      get :show, {:id => forums(:one)}, {:user => profiles(:user).id}
      assert_response 200
      assert_template 'show'
    end 
  end

  should "get show as :admin" do
    assert_nothing_raised do
      get :show, {:id => forums(:one)}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'show'
    end
  end

  ##
  # :new

  should "not get new for :user" do
    assert_nothing_raised do
      get :new, {}, {:user => profiles(:user).id}
      assert_response 302
      assert flash[:error]
    end
  end

  should "get new for :admin" do
    assert_nothing_raised do
      get :new, {}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'new'
    end
  end

  ##
  # create

  should "not create a new forum for :user" do
    assert_nothing_raised do
      assert_no_difference "Forum.count" do
        post :create, {:forum => valid_forum_attributes}, {:user => profiles(:user).id}
        assert_response 302
        assert flash[:error]
      end
    end
  end

  should "create a new forum for :admin" do
    assert_nothing_raised do
      assert_difference "Forum.count" do
        post :create, {:forum => valid_forum_attributes}, {:user => profiles(:admin).id}
        assert_redirected_to :controller => 'forums', :action => 'index'
      end
    end
  end
   
  should "not create a new forum for :user .xml" do
    assert_nothing_raised do
      assert_no_difference "Forum.count" do
        post :create, {:format=>'xml', :forum => valid_forum_attributes}, {:user => profiles(:user).id}
        assert_response 302
      end
    end
  end

  should "create a new forum for :admin .xml" do
    assert_nothing_raised do
      assert_difference "Forum.count" do
        post :create, {:format=>'xml', :forum => valid_forum_attributes}, {:user => profiles(:admin).id}
        assert_response 200
      end
    end
  end

  ##
  # :edit

  should "not get edit for :user" do
    assert_nothing_raised do
      get :edit, {:id => forums(:one).id}, {:user => profiles(:user).id}
      assert_response 302
      assert flash[:error]
    end
  end

  should "get edit for :admin" do
    assert_nothing_raised do
      get :edit, {:id => forums(:one).id}, {:user => profiles(:admin).id}
      assert_response 200
      assert_template 'edit'
    end
  end

  ##
  # :update

  should "not update a forum for :user" do
    assert_nothing_raised do
      put :update, {:id => forums(:one).id, :forum => valid_forum_attributes}, {:user => profiles(:user).id}
      assert_response 302
      assert flash[:error]
    end
  end

  should "update a forum for :admin" do
    assert_nothing_raised do
      put :update, {:id => forums(:one).id, :forum => valid_forum_attributes}, {:user => profiles(:admin).id}
      assert_redirected_to :controller => 'forums', :action => 'index' #, :id => forums(:one).to_param
    end
  end
  
  should "not update a forum for :admin" do
    assert_nothing_raised do
      put :update, {:id => forums(:one).id, :forum => unvalid_forum_attributes}, {:user => profiles(:admin).id}
      assert_response 200
    end
  end
     
  should "not update a forum for :user xml" do
    assert_nothing_raised do
      put :update, {:format=>'xml', :id => forums(:one).id, :forum => valid_forum_attributes}, {:user => profiles(:user).id}
      assert_response 302
    end
  end

  should "update a forum for :admin xml" do
    assert_nothing_raised do
      put :update, {:format=>'xml', :id => forums(:one).id, :forum => valid_forum_attributes}, {:user => profiles(:admin).id}
      assert_response 200
    end
  end
  

  should "not update a forum for :admin xml" do
    assert_nothing_raised do
      put :update, {:format=>'xml', :id => forums(:one).id, :forum => unvalid_forum_attributes}, {:user => profiles(:admin).id}
      assert_response 422
    end
  end
  
  ##
  # :destroy

  should "not destroy a forum for :user" do
    assert_nothing_raised do
      assert_no_difference "Forum.count" do
        delete :destroy, {:id => forums(:one).id}, {:user => profiles(:user).id}
        assert_response 302
        assert flash[:error]
      end
    end
  end

  should "destroy a forum for :admin" do
    assert_nothing_raised do
      assert_difference "Forum.count", -1 do
        delete :destroy, {:id => forums(:one).id}, {:user => profiles(:admin).id}
        assert_redirected_to :controller => 'forums', :action => 'index'
      end
    end
  end

  should "destroy a forum for :admin .xml" do
    assert_nothing_raised do
      assert_difference "Forum.count", -1 do
        delete :destroy, {:format=>'xml', :id => forums(:one).id}, {:user => profiles(:admin).id}
        assert_response 200
      end
    end
  end
  
  should "change the positions of the forums" do
    assert_no_difference "Forum.count" do
      assert_difference "Forum[forums(:one).id].position", 1 do
        assert_difference "Forum[forums(:two).id].position", -1 do
          post :update_positions, {:forums_list=>[forums(:two).id, forums(:one).id]}, {:user => profiles(:admin).id}
          assert_response 200
        end
      end
    end
  end

end
