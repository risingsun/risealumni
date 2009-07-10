xml = xml_instance unless xml_instance.nil?
xml.item do
  f = feed_item.item
  xml.title "#{f.full_name} has updated their profile"
  xml.description "#{f.full_name} has updated their profile"
  xml.author "#{f.email} (#{f.full_name})"
  xml.pubDate feed_item.created_at
  xml.guid profile_url(f)
end