class SiteContentSweeper < ActionController::Caching::Sweeper
  observe SiteContent
  
  def after_update(site_content)
    expire_cache
  end
  
  def expire_cache
    expire_fragment 'about_us'
    expire_fragment 'academics'
    expire_fragment 'contact_us'
    expire_fragment 'credits'
    expire_fragment 'members'
    expire_fragment 'tos'
    expire_fragment 'blurb'
    expire_fragment 'footer'
  end
  
end
