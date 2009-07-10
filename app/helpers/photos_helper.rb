module PhotosHelper
  def display_image photo, size = :orignal, img_opts = {}
    img_tag = image_tag(photo.image.url, {:title=>photo.caption, :alt=>photo.caption, :class=>size}.merge(img_opts))
    img_tag
  end
  def is_blurb_image?(flag)
    flag == "true" ? true : false
  end
  def page_title(flag)
    is_blurb_image?(flag) ? 'Blurb Image' : 'Photo'
  end
end
