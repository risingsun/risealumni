module FlickrHelperPatch
  def paginate_sets_images(arg, options = {})
    page     = options.delete(:page) || 1
    per_page = options.delete(:per_page) || self.per_page
    total    = options.delete(:total_entries)
    #page, per_page, total = wp_parse_options!(options)
    pager = WillPaginate::Collection.new(page, per_page, total)
    result = flickr_images_by_photoset(arg, per_page,page)
    returning WillPaginate::Collection.new(page, per_page, total) do |pager|
      pager.replace result
    end
  end    
  
  def paginate_unsets_images(options = {})
    page     = options.delete(:page) || 1
    per_page = options.delete(:per_page) || self.per_page
    total    = options.delete(:total_entries)
    pager = WillPaginate::Collection.new(page, per_page, total)
    result = unsets_flickr_pictures(per_page,page)
    returning WillPaginate::Collection.new(page, per_page, total) do |pager|
      pager.replace result
    end
  end    

  
end
