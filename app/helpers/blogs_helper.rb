module BlogsHelper
  def blog_body_content blog
    
    youtube_videos = blog.body.scan(/\[youtube:+.+\]/)
    out = blog.body.dup.gsub(/\[youtube:+.+\]/, '')
    unless youtube_videos.empty?
      out << <<-EOB
    
      EOB
      youtube_videos.each do |o|
        out << tb_video_link(o.gsub!(/\[youtube\:|\]/, ''))
      end
    end
    out
  end

end
