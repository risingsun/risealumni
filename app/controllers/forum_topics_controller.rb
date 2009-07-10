class ForumTopicsController < ApplicationController
  
  helper ForumsHelper
  
  before_filter :setup
  layout "plain"
  
  def index
    redirect_to forum_path(@forum)
  end
  
  def show
    @posts = @topic.posts.paginate(:all, :page => params[:page],:per_page => BLOGS_PER_PAGE, :order => 'created_at DESC')
    get_response
  end

  def new
    get_response
  end

  def edit
  end

  def create
    @topic = @forum.build_topic(params[:forum_topic].merge({:owner => @p}))
    post_response @topic.save
  end

  def update
    post_response @topic.update_attributes(params[:forum_topic])
  end

  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to(@forum) }
      format.xml  { head :ok }
    end
  end
  
  private

  def setup
    @forum = Forum.find(params[:forum_id])
    @topic = params[:id] ? @forum.topics.find(params[:id]) : @forum.topics.build
  end
  
  def post_response saved
    respond_to do |format|
      if saved
        format.html do 
          flash[:notice] = 'ForumTopic was successfully saved.'
          redirect_to(forum_path(@topic.forum)) 
        end
        format.xml  { render :xml => @topic}
      else
        format.html { render :action => (action_name == 'create' ? "new" : "edit") }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def get_response
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  def allow_to
    super :admin, :all => true
    super :active_user, :only => [:new, :create,:index, :show]
  end

end
