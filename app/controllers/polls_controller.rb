class PollsController < ApplicationController

  before_filter :setup
  # GET /polls
  # GET /polls.xml
  def index
    @polls = Poll.paginate_all_by_profile_id(@profile, 
                                             :order => 'created_at desc', 
                                             :page => params[:page], 
                                             :per_page => POLLS_PER_PAGE)
    if @p && @p == @profile && @p.polls.empty?
      flash[:notice] = 'You have not create any polls. Try creating one now.'
      redirect_to new_profile_poll_path(@p) and return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.rss {render :layout => false}
    end
  end

  # GET /polls/1
  # GET /polls/1.xml
  def show
    @poll = @profile.polls.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @poll }
    end
  end

  # GET /polls/new
  # GET /polls/new.xml
  def new
    @poll = @p.polls.new
   
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @poll }
    end
  end

  # GET /polls/1/edit
  def edit
    @poll = @p.polls.find(params[:id])
  end

  # POST /polls
  # POST /polls.xml
  def create
     @poll = @p.polls.build(params[:poll])
     
     respond_to do |format|
      if @poll.save
        params[:poll][:poll_option_attributes] ||= {}
        flash[:notice] = 'Poll was successfully created.'
        format.html { redirect_to profile_polls_path(@p) }
        format.xml  { render :xml => @poll, :status => :created, :location => @poll }
      else
        flash.now[:error] = 'Poll was not successfully created.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @poll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /polls/1
  # PUT /polls/1.xml
  def update
    @poll = @p.polls.find(params[:id])

    respond_to do |format|
      if @poll.update_attributes(params[:poll])
        flash[:notice] = 'Poll was successfully updated.'
        format.html { redirect_to profile_polls_path(@p) }
        format.xml  { head :ok }
      else
        flash.now[:error]= 'Poll was  not successfully updated.'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @poll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /polls/1
  # DELETE /polls/1.xml
  def destroy
    @poll = @p.polls.find(params[:id])
    @poll.destroy
    respond_to do |format|
      format.html { redirect_to profile_polls_path(@p) }
      format.xml  { head :ok }
    end
  end
  
  def poll_close
    @poll = @p.polls.find(params[:id])
    @poll.update_attributes(:status => false)
    respond_to do |format|
      format.html { redirect_to profile_polls_path(@p) }
      format.xml  { head :ok }
    end
  end
    
  protected
  
  def setup
    @profile = Profile[params[:profile_id]]
    @user = @profile.user
  end
    
  def allow_to
    super :owner, :all => true 
    super :active_user, :only => [:index, :show]
  end
  
end
