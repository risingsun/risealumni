require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase

  should 'create new feed_item and feeds after creating a blog post' do
    assert_difference "FeedItem.count" do
      assert_difference "Feed.count", 2 do
        p = profiles(:user)
        assert p.blogs.create(:title => 'this is a test post', :body => 'omg yay test!')
      end
    end
  end
  
  should_have_many :comments
  
  should_belong_to :profile
  
  should_require_attributes :title, :body
  
  should "call param" do
    b = blogs(:first)
    assert_not_nil b.to_param
  end
 
  should 'show unsent blogs' do
    assert_not_nil Blog.unsent_blogs
  end

  should 'show blog groups' do
    b = Blog.blog_groups
    assert b
    assert b.kind_of?(Array)
    assert_equal "May", b[0].month
    assert_equal "August", b[1].month
    assert_equal "July", b[2].month
    assert_equal "February", b[3].month
    assert_equal "2009", b[0].year
    assert_equal "2008", b[1].year
    assert_equal "2008", b[2].year
    assert_equal "2007", b[3].year
  end

  should 'check latest comments' do
    b = blogs(:first)
    p = profiles(:user)
    assert_not_nil b.commented_users(p)
    assert b.commented_users(p).kind_of?(Array)
    assert_equal blogs(:first).id, b.commented_users(p).first.commentable_id
    assert_equal "A comment", b.commented_users(p).first.comment
  end

  should 'test sent by' do
    b = blogs(:first)
    assert_not_nil b.sent_by
    assert_equal "De Veloper", b.sent_by
  end
  
  should 'search blog'do
    assert_not_nil Blog.search_blog("blog")
  end
  

  def test_associations
    _test_associations
  end
end
