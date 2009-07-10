
xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{@profile.full_name}'s Blog"
    xml.link SITE
    xml.description "#{@profile.full_name}'s Blog at #{SITE_NAME}"
    xml.language 'en-us'
    @blogs.each do |blog|
      xml.item do
        xml.title blog.title
        xml.description blog.body
        xml.author "#{@profile.full_name}"
        xml.pubDate @profile.created_at
        xml.link profile_blog_url(@profile, blog)
        xml.guid profile_blog_url(@profile, blog)
      end
    end
  end
end