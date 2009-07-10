class ForumsController < ApplicationController
  before_filter :setup
  layout "plain"

  def index
    @forums = Forum.find(:all, :order => "position DESC")
    get_response :xml_object => @forums
  end

  def show
    get_response
  end

  def new
    get_response
  end

  def edit
  end

  def create
    @forum = Forum.new(params[:forum])
    post_response @forum.save
  end

  def update
    post_response @forum.update_attributes(params[:forum])
  end

  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to(forums_path) }
      format.xml  { head :ok }
    end
  end
  
  def update_positions
    params[:forums_list].each_index do |i|
      forum = Forum.find(params[:forums_list][i])
      forum.position = i
      forum.save
    end
    render :nothing => true
  end
  
  private
  
  def setup
    if params[:id]
      @forum = Forum.find(params[:id], :include => :topics, :order => "forum_topics.created_at DESC")
      @topics = @forum.topics.paginate(:all, :page => params[:page],:per_page => BLOGS_PER_PAGE)
      @topic = @forum.topics.new
    else
      @forum = Forum.new
    end
  end
  
  def get_response options = {}
    options[:xml_object] ||= @forum
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => options[:xml_object] }
    end
  end
  
  def post_response saved
    respond_to do |format|
      if saved
        format.html do
          flash[:notice] = 'Forum was successfully saved.'
          redirect_to(forums_path)
        end
        format.xml  { render :xml => @forum, :location => @forum }
      else
        format.html { render :action => action_name == 'create' ? "new" : "edit" }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def allow_to
    super :admin, :all => true
    super :active_user, :only => [:index, :show]
  end
  
end
