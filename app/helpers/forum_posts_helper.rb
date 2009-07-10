module ForumPostsHelper
  
  def forum_posts_li post
    if post.topic and post.topic.forum
       "In #{link_to sanitize(post.topic.title), forum_topic_path(post.topic.forum, post.topic), :href => forum_topic_path(post.topic.forum, post.topic)+'#'+dom_id(post)  } #{time_ago_in_words post.created_at} ago"
    end
  end
  def owner(post)
    post.owner == @p
  end
end
