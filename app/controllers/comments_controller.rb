class CommentsController < ApplicationController
  skip_filter :store_location, :only => [:create, :destroy]
  before_filter :setup
  
  def index
    @comments = Comment.between_profiles(@p, @profile).paginate(:page => @page, :per_page => @per_page) # TODO Paginate
    redirect_to @p and return if @p == @profile
    respond_to do |wants|
      wants.html {render}
      wants.rss {render :layout=>false}
    end
  end
  
  def create
    @comment = @parent.comments.new(params[:comment].merge(:profile_id => @p.id))
    respond_to do |wants|
      if @comment.save
        if @parent == @blog
          @profile = @blog.profile
          @tamplate_bundle_id = BLOG_COMMENT_BUNDLE_ID
          data = {:titleText => @blog.title,:blog => "<a href='#{profile_blog_url(@blog.profile,@blog)}'>Rise Alumni</a>",:comment => @comment.comment}.to_json
          ArNotifier.deliver_comment_send_on_blog(@comment,@profile,@p) if @profile.wants_blog_comment_email_notification?
          @blog.commented_users(@p.id).each do |comment|
            ArNotifier.deliver_comment_send_on_blog_to_others(@comment,comment.profile,@p,@blog.profile) if comment.profile.wants_blog_comment_email_notification?
          end
        elsif @parent == @profile
          @tamplate_bundle_id = PROFILE_COMMENT_BUNDLE_ID
          data = {:userprofile => "<a href='#{profile_url(@profile)}'>Rise Alumni</a>"}.to_json
          ArNotifier.deliver_comment_send_on_profile(@comment,@parent,@p) if @profile.wants_profile_comment_email_notification?
        end
        wants.js do
          render :update do |page|
            page["#{dom_id(@parent)}_new_comment".to_sym].set_style :display => 'none' if @parent == @blog
            page.replace_html "#{dom_id(@parent)}_comment_size", :inline => pluralize(@parent.comments.size,'Comment') if @parent == @blog
            page.insert_html :top, "#{dom_id(@parent)}_comments", :partial => 'comments/comment',:locals =>{:comment => @comment}
            page.visual_effect :highlight, "comment_#{@comment.id}".to_sym
            page << "jq('#comment_comment').val('');"
            page << "facebook_publish_feed_story('#{Facebooker.api_key}',#{@tamplate_bundle_id},#{data},#{@profile.user.facebook_uid},'');" if current_facebook_user_logedin?
          end
        end
      else
        wants.js do
          render :update do |page|
            page << "message('Oops! Error creating that comment');"
          end
        end
      end
    end
  end


  def destroy
    comment = Comment.find(params[:id])
    if comment.commentable_type == 'Blog'
      blog_comment = true 
      @blog = Blog.find(comment.commentable_id)
    end
    comment.destroy
    respond_to do |wants|
      wants.html do
        flash[:notice]='comment was deleted.'
        redirect_back_or_default(profiles_path)
      end
      wants.js do 
        render :update do |page|
          page.replace_html "#{dom_id(@blog)}_comment_size", :inline => pluralize(@blog.comments.size,'Comment') if blog_comment
          page.visual_effect :fade, "comment_#{params[:id]}".to_sym
        end
      end
    end
  end

  protected
    
  def parent; @blog || @profile ||@event|| nil; end
    
  def setup
    @profile = Profile[params[:profile_id]] if params[:profile_id]
    @user = @profile.user if @profile
    @blog = Blog.find(params[:blog_id]) unless params[:blog_id].blank?
    @event = Event.find(params[:event_id]) unless params[:event_id].blank?
    @parent = parent
  end
  
  def allow_to
    super :active_user, :only => [:index, :create,:destroy]
  end

end
