module CommentsHelper
  
  def check_comment(comment)
    return true if @p.id == comment.profile_id
    if comment.commentable_type == 'Blog'
      return true if (Blog.find(comment.commentable_id)).profile_id == @p.id
    elsif comment.commentable_type  == 'Profile'
      return true if comment.commentable_id == @p.id
    elsif comment.commentable_type  == 'Event'
      return true if @u.is_admin?
    end
  end
  
end
