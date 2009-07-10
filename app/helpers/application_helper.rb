module ApplicationHelper
  include TagsHelper
  def less_form_for name, *args, &block
    options = args.last.is_a?(Hash) ? args.pop : {}
    options = options.merge(:builder=>LessFormBuilder)
    args = (args << options)
    form_for name, *args, &block
  end

  def display_standard_flashes(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
      flash_message_class = 'notice_msg'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
      flash_message_class = 'warning_msg'
    elsif flash[:error]
      flash_message_class = 'error_msg'
      level = 'error'
      if flash[:error].instance_of?( ActiveRecord::Errors) || flash[:error].is_a?( Hash)
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    flash_message_class = flash_message_class.to_s + " " + "widget_flash_msg"
    flash_msg = flash_to_display.to_s + "<span class='widget_flash_msg_btm'></span>"
    content_tag 'div', flash_msg, :class => flash_message_class, :id => "flash_message"
  end
  
  def display_standard_flashes_in_large_size(message = 'There were some problems with your submission:')
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
      flash_message_class = 'notice_msg'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
      flash_message_class = 'warning_msg'
    elsif flash[:error]
      flash_message_class = 'error_msg'
      level = 'error'
      if flash[:error].instance_of?( ActiveRecord::Errors) || flash[:error].is_a?( Hash)
        flash_to_display = message
        flash_to_display << activerecord_error_list(flash[:error])
      else
        flash_to_display = flash[:error]
      end
    else
      return
    end
    flash_message_class = flash_message_class.to_s + " " + "widget_large_flash_msg"
    flash_msg = flash_to_display.to_s + "<span class='widget_large_flash_msg_btm'></span>"
    content_tag 'div', flash_msg, :class => flash_message_class, :id => "flash_message"
  end

  def activerecord_error_list(errors)
    error_list = '<ul class="error_list">'
    error_list << errors.collect do |e, m|
      "<li>#{e.humanize unless e == "base"} #{m}</li>"
    end.to_s << '</ul>'
    error_list
  end
   
  
  def me(profile= @profile)
    @p == profile
  end
    
  def admin
    @p.user.is_admin
  end
  
  def is_admin?(user = nil)
    user && user.is_admin?
  end
  
  def if_admin
    yield if is_admin?(@u)
  end
  
  def slide_up_down_header(inner_panel_style,
      inner_panel_id,
      header_text)
    img_src = inner_panel_style == 'hide' ? 'show.jpg' : 'hide.jpg'
    @template.content_tag :h2,
      :class => "widget_lrg_title", 
      :id => inner_panel_id+"_header", 
      :onclick => "new Effect.SlideUpAndDown('#{inner_panel_id}', '#{inner_panel_id}_header', this);" do
      header_text + image_tag(img_src, :class=>"show_hide_img", :id => inner_panel_id+"_header_img")
    end
  end

  def flickr_link(f,urlt='t',c='blog_pix')
    link_to(image_tag(f.url("#{urlt}"), :alt => 'FlickrHolder', :class => "#{c}"),
      "http://www.flickr.com/photos/#{f.owner_id}/#{f.id}", 
      {:target => '_blank'})
  end
  
  def flickr_image(f,urlt='t')
    image_tag(f.url("#{urlt}"),:title => "#{f.title}")
  end
 
  def sets_pictures_link(photoset = nil, urlt='t')
    img = flickr_images_by_photoset(photoset, 1, 1)[0].url("#{urlt}")
    link_to(image_tag(img, :alt => "PhotoSet"),
      set_gallery_path(photoset.id).add_param(:height=>'500',:width=>'900'),:class=>'thickbox',:title => flickr.photosets.getInfo(photoset).title)
  end

  def unsets_pictures_link(f,urlt='t')
    link_to(image_tag(f.url("#{urlt}"), :alt => 'FlickrHolder'),
      gallery_path.add_param(:height=>'500',:width=>'500'),:class=>'thickbox',:title => flickr.photosets.getInfo(f).title )
  end
  
  def flickr_link_set_picture(f)
    ownerid = flickr.photos.getInfo(f).owner_id
    link_to(image_tag(f.url, :alt => 'FlickrHolder'),
      "http://www.flickr.com/photos/#{ownerid}/#{f.id}",
      {:target => '_blank'})
  end
  
  def message_count(profile = @p)
    c = profile.unread_messages.size
    "(#{c})" if c > 0
  end
  
  def current_announcements
    @current_announcements ||= Announcement.current_announcements(session[:announcement_hide_time])
  end
  
  def formatted_error_message(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          error_message_class = 'error_msg' + " " + "widget_flash_msg"
          html[key] = error_message_class
        end
      end
      options[:object_name] ||= params.first
      options[:message] ||= 'There were some problems with your submission:' unless options.include?(:message)
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }

      contents = ''
      contents << options[:message] unless options[:message].blank?
      contents << content_tag(:ul, error_messages)
      contents << "<span class='widget_flash_msg_btm'></span>"

      content_tag(:div, contents, html)
    else
      ''
    end
  end

  def inline_bar_graph(fill,batch_count)
    content_tag(:div, content_tag(:div, 
        content_tag(:p, "#{batch_count} Members", :class => "filled_text"), 
        :class => "filled", 
        :style => "width: #{fill}%;"),:class =>"fill_bar")
  end

  def valid_email(email)
    email =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  end

  # TODO: Remove this method when upgrading from Rails 2.1 to the next version
  def link_to(*args,&block)
    if block_given?
      concat(super(capture(&block), *args))
    else
      super(*args)
    end
  end

  def rounded_corner(options = {}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options.symbolize_keys!
    size = (options[:size] || :lrg).to_s
    title = options[:title] || ""
    concat(content_tag(:div, :class => "widget_#{size}") do 
        content_tag(:span, " ", :class => "widget_#{size}_top") +
          content_tag(:h2,title,:class => "widget_#{size}_title") +
          capture(&block) +
          content_tag(:div, "", :class => "clear_div") +
          content_tag(:span, "", :class => "widget_#{size}_btm")
      end)
  end

  def rounded_med_corner(options = {}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options.symbolize_keys!
    title = options[:title] || ""
    id = options[:id] || title
    button = options[:button] || ""
    concat(content_tag(:div, :class => "edit_profile", :id => id) do 
        content_tag(:span, " ", :class => "edit_profile_top") +
          content_tag(:h2,title,:class => "edit_profile_title") +
          content_tag(:div, :class => "edit_panel_profile") do
          capture(&block)
        end +
          content_tag(:div, "", :class => "clear_div") +
          content_tag(:span, "", :class => "edit_profile_btm")
      end + (button.blank? ? "" : content_tag(:div, :class => "large_btn_container") do
          content_tag(:button, theme_image(button), :class => "buttons", :type => "submit")
        end))
  end
  
  def theme_image(img, options = {})
    "#{image_tag((THEME_IMG + "/" + img), options)}"
  end
  
  def tb_video_link youtube_unique_path
    return if youtube_unique_path.blank?
    youtube_unique_id = youtube_unique_path.split(/\/|\?v\=/).last.split(/\&/).first
    client = YouTubeG::Client.new
    video = client.video_by YOUTUBE_BASE_URL+youtube_unique_id rescue return "(video not found)"
    id = Digest::SHA1.hexdigest("--#{Time.now}--#{video.title}--")
    %(<strong>#{video.title}:</strong><br/>) + %(<div id="#{h id}">#{video.embed_html}</div>)
  end

  def display_alpha_index(list)
    str = ""
    list.each do |i|
      str << link_to(i, "##{i}_div")
      str << " "
    end
    str
  end


end
