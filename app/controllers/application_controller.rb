class ApplicationController < ActionController::Base
  helper :all
  include ExceptionNotifiable
  filter_parameter_logging "password"

  helper_method :flickr, :flickr_images, :flickr_photosets, :flickr_images_by_photoset
  before_filter :set_facebook_session
  helper_method :facebook_session,:current_facebook_user_logedin?

  before_filter :environments, :allow_to, :check_user, :login_from_cookie, :login_required, 
    :set_profile, :pagination_defaults, 
    :set_default_url_options_for_mailers,
    :check_access_permissions#, :check_permissions,
  after_filter  :store_location
  rescue_from Facebooker::Session::SessionExpired, :with => :facebook_session_expired

  def facebook_session_expired
    clear_fb_cookies!
    clear_facebook_session_information
    flash[:error] = "Your facebook session has been expired."
    redirect_back_or_default home_path()
 end
  
  def set_profile
    @p = @u.profile if @u && @u.profile
    @is_admin = @u.is_admin? if @u
  end
  
  def current_facebook_user_logedin?
    user = facebook_user
    user.nil? ? false : @u.facebook_uid == user.uid
  end
  
  def facebook_user
    facebook_session.try(:session_key) ? facebook_session.user : nil
  end
  
  def pagination_defaults
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @per_page = (params[:per_page] || (@test ? 1 : RESULT_PER_PAGE)).to_i
  end
  
  def set_default_url_options_for_mailers
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  def environments
    @production = RAILS_ENV == 'production'
    @development = RAILS_ENV == 'development'
    @test = RAILS_ENV == 'test'
  end

  # API objects that get built once per request
  def flickr
    @flickr_object ||= Flickr.new(FLICKR_CACHE, FLICKR_KEY, FLICKR_SECRET)
  end
  
  def flickr_images(user_name = "", tags = "", per_page = FLICKR_IMAGES, page = nil)
    unless @test
      begin
        flickr.photos.search(user_name.blank? ? nil : user_name, tags.blank? ? nil : tags , nil, nil, nil, nil, nil, nil, nil, nil, per_page, page)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end
  
  def flickr_photosets(user_name = "")
    unless @test
      begin
        flickr.photosets.getList(user_name.blank? ? nil : user_name)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end
  
  def flickr_images_by_photoset(photoset = nil, per_page = FLICKR_IMAGES, page = nil)
    unless @test
      begin
        flickr.photosets.getPhotos(photoset, nil, per_page, page)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end
  
  def search_results
    p = params[:search] ? params[:search].dup : {}
    @title = "Search"    
    @q , @q_val = p[:key] ? ["Search for Friends",p[:q]] : [p[:q],"Search"]      
    if p[:key] && p[:key]== "blog" # For Blog Search
      @blogs = Blog.search_blog(params[:search][:q])
      render :template =>"/blogs/search_blog"
    else
      @results = @p.search((p.delete(:q) || ''), p).paginate(:page => @page, :per_page => @per_page)
    end
  end
  
  def sorted_results(*args)
    args.flatten.sort_by(&:created_at).reverse
  end

  protected
  
  def allow_to level = nil, args = {}
    return unless level
    @level ||= []
    @level << [level, args]  
  end
  
=begin  
  def check_permissions
    logger.debug "IN check_permissions :: @level => #{@level.inspect}"
    return failed_check_permissions if @p && !@p.is_active
    return true if @u && @u.is_admin
    raise '@level is blank. Did you override the allow_to method in your controller?' if @level.blank?
    @level.each do |l|
      next unless (l[0] == :all) || 
        (l[0] == :non_user && !@u) ||
        (l[0] == :user && @u) ||
        (l[0] == :owner && @p && @p.id==(params[:profile_id] || params[:id]).to_i)
      args = l[1]
      @level = [] and return true if args[:all] == true

      if args.has_key? :only
        actions = [args[:only]].flatten
        actions.each{ |a| @level = [] and return true if a.to_s == action_name}
      end
    end
    return failed_check_permissions
  end
=end  

  def failed_check_permissions
    if !@development
      flash[:error] = 'It looks like you don\'t have permission to view that page.'
      redirect_back_or_default home_path and return true
    else
      render :text=><<-EOS
      <h1>It looks like you don't have permission to view this page.</h1>
      <div>
        Permissions: #{@level.inspect}<br />
        Controller: #{controller_name}<br />
        Action: #{action_name}<br />
        Params: #{params.inspect}<br />
        Session: #{session.instance_variable_get("@data").inspect}<br/>
      </div>
      EOS
    end
    @level = []
    false
  end

  def check_access_permissions
    #logger.debug "IN check_permissions :: @level => #{@level.inspect}"
    #return failed_check_access_permissions if @p && !@p.is_active
    raise '@level is blank. Did you override the allow_to method in your controller?' if @level.blank?
    @level.each do |l|
      next unless (l[0] == :all) || 
        (l[0] == :admin && @u && @u.is_admin) ||
        (l[0] == :non_user && !@u) ||
        (l[0] == :user && @u) || # TODO Remove this line later we dont need this line.
      (l[0] == :active_user && @u && @u.profile.is_active) ||
        (l[0] == :non_active_user && @u && !@u.profile.is_active) ||
        (l[0] == :owner && @p && @p.id==(params[:profile_id] || params[:id]).to_i)
      args = l[1]
      @level = [] and return true if args[:all] == true
      if args.has_key? :only
        actions = [args[:only]].flatten
        actions.each{ |a| @level = [] and return true if a.to_s == action_name}
      end
    end
    return failed_check_access_permissions
  end
  
  def failed_check_access_permissions
    if !@development
      flash[:error] = 'It looks like you don\'t have permission to view that page.'
      redirect_back_or_default home_path and return true
    else
      flash[:error] = 'It looks like you don\'t have permission to view that page.'
      redirect_back_or_default home_path and return true
    end
    @level = []
    false
  end
end
