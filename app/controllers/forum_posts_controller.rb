class ForumPostsController < ApplicationController
  before_filter :setup
  layout "plain"
   
  def create
    @post = @topic.posts.build(params[:forum_post])
    @post.owner = @p
    respond_to do |format|
      if @post.save
        format.html do
          flash[:notice] = 'ForumPost was successfully saved.'
          redirect_to(forum_topic_url(@forum, @topic))
        end
        format.xml  { render :xml => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @post = ForumPost.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(forum_topic_url(@forum, @topic)) }
      format.xml  { head :ok }
      format.js do
        render :update do |page|
          page.visual_effect :puff, @post.dom_id
        end
      end
    end
  end

  private

  def setup
    @forum = Forum.find(params[:forum_id])
    @topic = @forum.topics.find(params[:topic_id])
  end
  
  def allow_to
    super :admin, :all => true
    super :active_user, :only => [:new, :create,:index, :show,:destroy]
  end
  
end