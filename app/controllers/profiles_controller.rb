class ProfilesController < ApplicationController
  include ApplicationHelper
  in_place_edit_for :profile, :status_message
  before_filter :setup_user_profile, :except => [:index, :search,:update_email, :batch_details]
  before_filter :show_panels, :only => [:show, :batch_mates]
  before_filter :search_results, :only => [:index, :search]
  skip_filter :login_required, :only=>[:show, :index, :feed, :search, :update_email]
  cache_sweeper :profile_flickr_video_sweeper, :only => [:update]
  #caches_page :edit_account
  #cache_sweeper :edit_account_sweeper, :only => [:update]
  def show    
    when_fragment_expired "profile_#{@profile.id}/profile_flickr_pics_and_video#{@profile.id}",
      :expire => EXPIRE_TIME_IN_MIN.minutes.from_now do
      unless @profile.youtube_username.blank?
        begin
          client = YouTubeG::Client.new
          @video = client.videos_by(:user => @profile.youtube_username).videos.first
        rescue Exception, OpenURI::HTTPError
        end
      end
      begin
        @flickr = @profile.flickr_username.blank? ? [] : flickr_images(flickr.people.findByUsername(@profile.flickr_username), {}, FLICKR_IMGAES_ON_PROFILE)
      rescue Exception, OpenURI::HTTPError
        @flickr = []
      end
    end
    if @profile.can_see_field("marker", @p)
      @profiles = @profile.all_friends.select{|f|f.can_see_field('marker',@p)}
    end
    @comments = @profile.comments.paginate(:page => params[:page], :per_page => @per_page)
    @feed_items = @profile.find_feed_items
    respond_to do |wants|
      wants.html 
      wants.rss {render :layout => false}
    end
  end
  
  def search
    @title = "Search"
    render :template =>"shared/user_friends"
  end
  
  def index
    @title = "Profiles"
    render :template =>"shared/user_friends"
  end
  
  def edit
    render :layout => "plain"
  end
  
  def update
    case params[:switch]
    when 'profile', 'name'
      unless params[:profile].blank?
        params[:profile][:education_attributes] ||= {} # Attribute Fu 
        params[:profile][:work_information_attributes] ||= {} # Attribute Fu
      end
      if @profile.update_attributes params[:profile] and @user.update_attributes(params[:user])
        flash[:notice] = "Settings have been saved."
        redirect_to edit_profile_url(@profile)
      else
        render :action => :edit, :layout => "plain"
      end
    when 'password'
      if @user.change_password(params[:verify_password], params[:new_password], params[:confirm_password])
        flash[:notice] = "Password has been changed."
        redirect_to edit_account_profile_url(@profile)
      else
        render :action=> :edit_account, :layout => "plain"
      end
    when 'permissions'
      @profile.update_attributes params[:profile]
      flash[:notice] = "Settings have been saved."
      redirect_to edit_account_profile_url(@profile)
    when 'set_default_permissions'
      @profile.update_attributes params[:profile]
      @profile.permissions.each {|p| p.destroy}  # Delete the old 
      flash[:notice] = "Settings have been saved."
      redirect_to edit_account_profile_url(@profile)
    when 'request_email'
      if @user.request_email_change!(params[:user][:requested_new_email]) 
        AccountMailer.deliver_new_email_request(@user)
        flash[:notice] = "Email confirmation request has been sent to the new email address."
        redirect_to edit_account_profile_url(@profile)
      else
        render :action=> :edit_account, :layout => "plain"
      end
      
    else
      @test ? render( :text=>'') : raise( 'Unsupported swtich in action')
    end
  end

  # Update the status message for user
  def status_update
    @profile.update_attribute("status_message", params[:value])
    render :text => @profile.send("status_message") 
  end
  
  def delete_icon
    respond_to do |wants|
      @p.update_attribute :icon, nil
      wants.js {render :update do |page| page.visual_effect 'Fade', 'profile_icon_picture' end  }
    end      
  end

  def destroy
    respond_to do |wants|
      @user.destroy
      cookies[:auth_token] = {:expires => Time.now-1.day, :value => ""}
      session[:user] = nil
      wants.js do
        render :update do |page| 
          page.alert('Your user account, and all data, have been deleted.')
          page << 'location.href = "/";'
        end
      end
    end
  end
   
  def update_email
    @profile = Profile.find(params[:profile_id])
    unless @profile.user.match_confirmation?(params[:hash])
      flash[:notice] = "We're sorry but it seems that the confirmation did not go thru. You may have provided an expired key." #Text
    else
      @profile.email =  @profile.user.requested_new_email
      if  @profile.save
        flash[:notice] = "Your email has been updated" #Text
      else
        flash[:notice] = "This email has already been taken" #Text
      end
    end
    redirect_to home_path
  end
  
  def edit_account
    @notification_control = @p.notification_control
    render :layout => "plain"
  end
  
  def batch_mates
    @results = @profile.batch_mates(:page => params[:page], :per_page => @per_page)
    @title = "Group Members"
    render :template => "shared/user_friends"
  end
  
  def network
  end
  
  def followers
    @results = @profile.followers.paginate(:page => params[:page], :per_page => @per_page) # TODO Paginate
    @title = "Followers"
    render :template => "shared/user_friends"
  end
  
  def followings
    @results = @profile.followings.paginate(:page => params[:page], :per_page => @per_page) # TODO Paginate
    @title = "Followings"
    render :template => "shared/user_friends"
  end
  
  def batch_details
    @group = params[:group]
    if valid_batch_range
      @students  = StudentCheck.unregistered_batch_members(@group)
      @profiles = Profile.batch_details(@group, {:page => params[:page], :per_page => @per_page})
    else
      flash[:error] = 'Group is invalid! Sorry, please enter a valid group'
      redirect_back_or_default('/')
    end
  end
  
  def notification_control
    @profile.notification_control.update_attributes(params[:notification_control])
    flash[:notice] = "Notification Updated"
    redirect_to edit_account_profile_url(@profile)
  end
  
  private
  
  def allow_to
    super :owner, :all => true
    super :active_user, :only => [:show, :index, 
      :search,:batch_mates,
      :network,:followers,:followings,
      :batch_details] # only activated user can perform these action
    
    super :all, :only => [:update_email]
  end
  
  def setup_user_profile
    @profile = params[:id] == @p ? @p : Profile[params[:id]]
    @user = params[:id] == @p ? @u : @profile.user
  end
  
  def show_panels
    @show_profile_side_panel = true
  end

  def valid_batch_range(group = @group)
    !group.blank? && GROUPS.include?([group])
  end
  
end
