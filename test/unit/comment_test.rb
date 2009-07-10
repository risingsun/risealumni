require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase

  should_require_attributes :comment, :profile
  
  should_belong_to :commentable, :profile
  
  should "show me the wall between us" do
    comments = Comment.between_profiles profiles(:user), profiles(:user2)
    assert_equal 1, comments.size
    assert_equal [comments(:third).id], comments.map(&:id).sort

    assert profiles(:user).comments.create(:comment => 'yo', :profile => profiles(:user2))
    assert_equal 2, Comment.between_profiles( profiles(:user), profiles(:user2)).size
  end

  should "show me the wall between me" do
    comments = Comment.between_profiles profiles(:user), profiles(:user)
    assert_equal 1, comments.size
    assert_equal [comments(:seven).id], comments.map(&:id).sort
  end

  should 'create new feed_item and feeds after someone else creates a comment' do
    assert_difference "FeedItem.count" do
        p = profiles(:user)
        assert p.comments.create(:comment => 'omg yay test!', :profile_id => profiles(:user2).id)   
    end
  end
  
  should 'show recent comments' do
    comments = Comment.recent_comments
    assert_not_nil comments
  end

end