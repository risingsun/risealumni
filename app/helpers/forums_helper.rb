module ForumsHelper
  
  def forum_details(forum)
    "#{forum.posts.count} "+(forum.posts.count == 1 ? "post" : "posts")+" in #{forum.topics.count} "+(forum.topics.count == 1 ? "topic" : "topics")
  end
  
  def forum_last_post_info(forum)
    unless (forum.posts.empty?)
      post = forum.posts.last
      "#{post.created_at.to_datetime.to_formatted_s(:rfc822)}<br/>Posted by "+link_to(post.owner.f, profile_path(post.owner))+"<br/>in "+link_to(post.topic.title, forum_topic_path(post.topic.forum, post.topic))
    else
      "No posts"
    end
  end
end
