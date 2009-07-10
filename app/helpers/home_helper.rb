module HomeHelper
  
  def flickr_pictures(per_page = FLICKR_IMAGES, page = nil)
    begin
      FLICKR_USER_ACCOUNT.blank? ? [] : flickr_images(flickr.people.findByUsername(FLICKR_USER_ACCOUNT), {}, per_page, page)
    rescue Exception, OpenURI::HTTPError
      []
    end
  end
  
  def sets_flickr_pictures
    begin
      FLICKR_USER_ACCOUNT.blank? ? [] : flickr_photosets(flickr.people.findByUsername(FLICKR_USER_ACCOUNT))
    rescue Exception, OpenURI::HTTPError
      []
    end
  end
 
  def unsets_flickr_pictures(per_page = nil, page = nil)
    begin
      FLICKR_USER_ACCOUNT.blank? ? [] : flickr.photos.getNotInSet(nil, per_page, page)
    rescue Exception, OpenURI::HTTPError
      []
    end

  end

  def profile_link(first_name, last_name, group, full_name=nil)
    full_name ||= "#{first_name} #{last_name}"
    anchor = "#{full_name} (#{group})"
    profile = Profile.find_by_first_name_and_last_name_and_group(first_name, 
                                                                last_name, 
                                                                group)
    if profile.blank?
      "<p>#{anchor}</p>"
    else     
      "#{icon profile, :small_60, {:class => "featured_mem_pic"}, {:class => "featured_mem_text"} }" + "#{ link_to anchor, profile_url(profile) }"
    end
  end
  
  def cache_name_flickr(set_id,page)
    if set_id
      "flickr_gallery/#{set_id}/app_flickr#{page || 1}"
    else
      "flickr_gallery/gallery/app_flickr#{page || 1}"
    end
  end
end