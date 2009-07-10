class BlogsSweeper < ActionController::Caching::Sweeper
  include ActionController::UrlWriter

  observe Blog

  def after_create(blog)
    expire_cache(blog)
  end

  def after_destroy(blog)
    expire_cache(blog)
  end

  def after_update(blog)
    expire_cache(blog)
  end

  def expire_cache(blog)
    expire_fragment "profile_#{blog.profile_id}/profile_page_blogs"
  end

end