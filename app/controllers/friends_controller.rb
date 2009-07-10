class FriendsController < ApplicationController
  before_filter :setup
  #skip_before_filter :login_required, :only=>:index
  skip_before_filter :store_location, :only => [:create, :destroy]
  cache_sweeper :friend_sweeper, :only => [:create,:destroy] 
  def create
    respond_to do |wants|
      if Friend.make_friends(@p, @profile)
        friend = @p.reload.friend_of? @profile
        if params[:start_follow]
          @tamplate_bundle_id = FOLLOW_BUNDLE_ID
          @data = {:actorprofile => "<a href='#{profile_url(@profile)}'>Rise Alumni</a>"}.to_json
        else
          @data = {:userprofile => "<a href='#{profile_url(@profile)}'>Rise alumni</a>",:profile => "<a href='#{profile_url(@p)}'>Rise alumni</a>"}.to_json
          @tamplate_bundle_id = BE_FRIEND_BUNDLE_ID
        end
        wants.js do
          render( :update )do |page|
            page.replace @p.dom_id(@profile.dom_id + '_friendship_'), get_friend_link( @p, @profile)
            page << "facebook_publish_feed_story('#{Facebooker.api_key}',#{@tamplate_bundle_id},#{@data},#{@profile.user.facebook_uid},'');" if current_facebook_user_logedin?
          end
        end
      else
        message = "Oops... That didn't work. Try again!"
        wants.js {render( :update ){|page| page.alert message}}
      end
    end
  end
  
  def destroy
    Friend.reset @p, @profile
    respond_to do |wants|
      following = @p.reload.following? @profile
      ArNotifier.deliver_delete_friend(@p, @profile) if @profile.wants_delete_friend_email_notification?   
      Profile.admins.first.sent_messages.create( :subject => "[#{SITE_NAME} Notice] Delete friend notice", 
        :body => "#{@p.full_name} is Deleted you on #{SITE_NAME}",
        :receiver => @profile, :system_message => true ) if @profile.wants_delete_friend_message_notification?
      wants.js {render( :update ){|page| page.replace @p.dom_id(@profile.dom_id + '_friendship_'), get_friend_link( @p, @profile)}}
    end
  end

  def index
    @results = @profile.friends.paginate(:page => params[:page], :per_page => @per_page) # TODO Paginate
    @title = "Friends"
    render :template => "shared/user_friends"
  end
  
  protected
  
  def allow_to
    super :user, :all => true
    super :non_user, :only => :index
  end
  
  
  def setup
    @profile = Profile[params[:id] || params[:profile_id]]
    @user = @profile.user
  end
  
end
