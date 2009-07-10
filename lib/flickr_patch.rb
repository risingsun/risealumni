module FlickrPatch
  class Flickr::PhotoSets
    def getPhotos(photoset,extras=nil,per_page =nil, page = nil)
      photoset = photoset.id if photoset.class == Flickr::PhotoSet
      args = { 'photoset_id' => photoset }
      args['extras'] = extras if extras
      args['per_page'] = per_page if per_page
      args['page'] = page if page
      res = @flickr.call_method('flickr.photosets.getPhotos',args)
      return Flickr::PhotoSet.from_xml(res.root,@flickr)
    end
  end
end

