xml = xml_instance unless xml_instance.nil?
xml.item do
  b = feed_item.item
  xml.title "#{b.profile.full_name} blogged #{time_ago_in_words b.created_at} ago #{b.title}"
  xml.description b.body
  xml.author "#{b.profile.email} (#{b.profile.full_name})"
  xml.pubDate b.updated_at
  xml.link profile_blog_url(b.profile, b)
  xml.guid profile_blog_url(b.profile, b)
end