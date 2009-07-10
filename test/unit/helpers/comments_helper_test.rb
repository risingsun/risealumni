require File.dirname(__FILE__) + '/../../test_helper'

class CommentsHelperTest < ActionView::TestCase

  include CommentsHelper
  
  def test_check_comments
    @p = profiles(:user)
    c = check_comment(comments(:second))
    assert_not_nil c
  end

 def test_check_comments_if_commentable_type_is_profile
   @p = profiles(:user2)
   c = check_comment(comments(:third))
   assert_not_nil c
 end
   
end