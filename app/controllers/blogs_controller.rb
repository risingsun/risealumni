class BlogsController < ApplicationController
  #skip_filter :login_required, :only => [:index, :show] # Keep the blog private from non_user
  cache_sweeper :blogs_sweeper, :only => [:update,:create,:destroy]
  before_filter :setup,:except => [:auto_complete_for_blog_tag_list, :blogs_by_tag, :search_blog, :blog_archive]
  
  
  uses_tiny_mce(:only => [:new, :edit,:create,:update],
    :options => {
      :theme => 'advanced',
      :theme_advanced_toolbar_location => "bottom",
      :theme_advanced_toolbar_align => "left",
      :theme_advanced_resizing => true,
      :theme_advanced_resize_horizontal => false,
      :paste_auto_cleanup_on_paste => true,
      :theme_advanced_buttons1 => %w{bold italic underline strikethrough separator 
                                     justifyleft justifycenter justifyright indent 
                                     outdent separator bullist numlist separator 
                                     link unlink image undo redo code forecolor 
                                     backcolor newdocument cleanup},
      :theme_advanced_buttons2 => %w{formatselect fontselect fontsizeselect},
      :theme_advanced_buttons3 => [],
      :plugins => %w{contextmenu paste}})

  def index
    @blogs = @profile.blogs.paginate(
      :order => 'updated_at desc', 
      :page => params[:page], 
      :per_page => BLOGS_PER_PAGE)
    if @my_blog && @blogs.empty?
      flash[:notice] = 'You have not create any blog posts. Try creating one now.'
      redirect_to new_profile_blog_path(@p) and return
    end
    @facebook_publish_feed_story = params[:facebook_publish] if current_facebook_user_logedin?
    respond_to do |wants|
      wants.html
      wants.rss {render :layout => false}
    end
  end

  def new
    @blog = @profile.blogs.build
  end

  def create
    @blog = @profile.blogs.build params[:blog]
    respond_to do |wants|
      if params[:preview_button]
        wants.html do
          render :action => :new
        end
      elsif @blog.save
        tamplate_bundle_id = BLOG_BUNDLE_ID
        data = {:blog_title => "<a href='#{profile_blog_url(@blog.profile,@blog)}'>#{@blog.title}</a>"}.to_json
        facebook_publish = "facebook_publish_blog_story('#{Facebooker.api_key}',#{tamplate_bundle_id},#{data});"
        wants.html do
          flash[:notice] = 'New blog post created.'
          redirect_to profile_blogs_path(@p).add_param(:facebook_publish => facebook_publish)
        end
      else
        wants.html do
          flash.now[:error] = 'Failed to create a new blog post.'
          render :action => :new
        end
      end
    end
  end
    
  def show
    @blog = @profile.blogs.find(params[:id])
    @page_no = params[:page]
  end
  
  def edit
    @blog = @profile.blogs.find(params[:id])
    render
  end
  
  def update
    @blog = @profile.blogs.find(params[:id])
    respond_to do |wants|
      if params[:preview_button]
        @blog.title = params[:blog][:title]
        @blog.body = params[:blog][:body]
        @blog.public = params[:blog][:public]
        wants.html do
          render :action => :edit
        end
      elsif @blog.update_attributes(params[:blog])
          tamplate_bundle_id = BLOG_BUNDLE_ID
          data = {:blog_title => "<a href='#{profile_blog_url(@blog.profile,@blog)}'>#{@blog.title}</a>"}.to_json
          facebook_publish = "facebook_publish_blog_story('#{Facebooker.api_key}',#{tamplate_bundle_id},#{data});"
        wants.html do
          flash[:notice]='Blog post updated.'
          redirect_to profile_blogs_path(@p).add_param(:facebook_publish => facebook_publish)
        end
      else
        wants.html do
          flash.now[:error]='Failed to update the blog post.'
          render :action => :edit
        end
      end
    end
  end
  
  def destroy
    @blog = @profile.blogs.find(params[:id])
    @blog.destroy
    respond_to do |wants|
      wants.html do
        flash[:notice]='Blog post deleted.'
        redirect_to profile_blogs_path(@p)
      end
    end
  end
  
  def search_blog
    @title = "Search"
    @q = params[:search][:blog]
    unless params[:search][:blog].blank?
      @blogs = Blog.search_blog(params[:search][:blog]) 
    else
      redirect_back_or_default('/')
    end
    
  end
  
  def blogs_by_tag
    tag = Tag.find(params[:tag_id])
    @blogs = Blog.find_tagged_with(tag)
    @title = "Blogs about #{tag}"
    render :action => :search_blog
  end
  
  def blog_archive
    @blogs = Blog.by_month_year(params[:month],params[:year]).all.paginate(:page => params[:page],:per_page => BLOGS_PER_PAGE)
  end
  
  protected
   
  def setup
    @my_blog = params[:profile_id].to_i == @p.id
    @profile = @my_blog ? @p : Profile.find(params[:profile_id])
  end
  
  def allow_to
    super :owner, :all => true 
    super :active_user, :only => [:index, :show, :search_blog, :blogs_by_tag, :blog_archive]
  end
  
end

