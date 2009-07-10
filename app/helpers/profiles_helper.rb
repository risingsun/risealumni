require 'avatar/view/action_view_support'

module ProfilesHelper
  include Avatar::View::ActionViewSupport

  def icon profile, size = :small, img_opts = {}, link_opts = {}
    return "" if profile.nil?
    img_opts = {:title => profile.full_name, :alt => profile.full_name, :class => size}.merge(img_opts)
    link_to(avatar_tag(profile, {:gender => profile.gender_str, :size => size, :paperclip_style => size }, img_opts), profile_url(profile), link_opts)
  end

  def location_link profile = @p
    return profile.location if profile.location == Profile::NOWHERE
    link_to h(profile.location), search_profiles_path.add_param('search[location]' => profile.location)
  end
  
  def show_field(profile_field, profile, field)
    "<tr><th align='right'>#{field.titleize}</th><td>#{profile_field}</td></tr>" if profile.can_see_field(field, @p)
  end
  
  def year_link profile = @p
    link_to h(profile.group), search_profiles_path.add_param('search[group]' => profile.group)
  end
  
  def name_year(p)
    p.f + "<br />" + p.group
  end
  
  def skype_status(skype_account)
    str = ""
    unless skype_account.blank?
      str = '<script type="text/javascript" src="http://download.skype.com/share/skypebuttons/js/skypeCheck.js"></script>'
      str += "<a href='skype:#{skype_account}?call'><img src='http://mystatus.skype.com/bigclassic/#{skype_account}' style='border: none;' width='182' height='44' alt='My status' /></a>"
    end
    str
  end
  
  def msn_status(msn_account)
    str = ""
    unless msn_account.blank?
      str = "<a href='msnim:add?contact=#{msn_account}'>"
      str += '<img src="http://microsoftwlmessengermkt.112.2o7.net/b/ss/mswlmmktbuttoncom/1/H.9--NS/1?ns=microsoftwlmessengermkt&pageName=Button&20Impression&c7=B&c8=Orange&c9=Connect&c10=B:Orange:Connect" width="1" height="1" border="0" />'
      str += '<img src="http://global.msads.net/ads/pronws/B_Orange_Connect.png" style="Clear: Both; Padding-Bottom: 10px; Border: 0px" /></a>'
    end
    str
  end
  
  def yahoo_status(yahoo_username)
    str = ""
    unless yahoo_username.blank?
      str = "<b>Yahoo:</b> #{yahoo_username}<br/><img src='http://opi.yahoo.com/online?u=#{yahoo_username}&m=g&t=2&l=us&opi.jpg'/>"
    end
    str
  end
  
  def linkedin_badge(linkedin_name)
    str = ""
    unless linkedin_name.blank?
      str = "<a href='http://www.linkedin.com/in/#{linkedin_name}'>"
      str += "<img src='http://www.linkedin.com/img/webpromo/btn_myprofile_160x33.gif' width='160' height='33' border='0' alt='View #{@profile.full_name}\'s profile on LinkedIn'></a>"
    end
    str
  end
  
  def status_in_place_editor
    in_place_editor_field :profile, 
                          'status_message', {}, 
                          {:url => status_update_profile_path(@p),
                           :save_text => "" , 
                           :click_to_edit_text => "Click here to set your status..!!", 
                           :cancel_text => "",
                           :size => "50"}
  end
  
  def get_batch_year
    @group || (@profile && @profile.group) || (@p && @p.group) || Date.today.year
  end
  
  def before_after(field_index)
    if field_index < 0
      return "recent"
    elsif field_index == 0
      return "today"
    end
    return "upcoming"
  end
  
  def new_map
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true, :map_type => true)
    @map.center_zoom_init([GOOGLE_MAP_DEFAULT_LAT,GOOGLE_MAP_DEFAULT_LON],GOOGLE_MAP_DEFAULT_ZOOM)
    @map.record_init('create_draggable_editable_marker();')
  end

  def edit_map(marker)
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true, :map_type => true)
    @map.center_zoom_init([marker.lat,marker.lng],marker.zoom)
    @map.record_init("create_draggable_marker_for_edit(#{marker.lat},#{marker.lng},#{marker.zoom});")
  end

  def show_map
    @map = GMap.new("map_div")
    unless @profiles.blank? 
      @map.control_init(:large_map => true,:map_type => true)  
      @map.set_map_type_init(GMapType::G_HYBRID_MAP)
      markers = @profiles.collect do |f|
        GMarker.new([f.marker.lat,f.marker.lng],
          :title => "#{f.full_name({:is_short => 1})}",
          :info_window => "#{icon(f)} #{f.full_name({:is_short=>1})}'s Location.")
      end
      p = @profile ? @profile : @p
      centre = p.marker.nil? ? @profiles.first.marker : p.marker    
      @map.center_zoom_init([centre.lat,centre.lng],centre.zoom)
      @map.overlay_global_init(GMarkerGroup.new(true,markers),"my_friends")
    end
  end
end
