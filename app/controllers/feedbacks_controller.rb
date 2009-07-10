class FeedbacksController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
  
  def index
    @feedbacks = Feedback.paginate(:order => 'created_at DESC', :page => @page, :per_page => @per_page)
    render :layout => "admin"
  end

  def new
    @feedback = Feedback.new
  end

  def create
    if @p
      @feedback = @p.feedbacks.new(params[:feedback])
    else
      @feedback = Feedback.new(params[:feedback])
    end
    @feedback.captcha = params[:feedback][:captcha]
    @feedback.captcha_answer = params[:feedback][:captcha_answer]
    respond_to do |wants|
      if @feedback.save
        flash[:notice] = "Thank you for your message.  A member of our team will respond to you shortly."
        wants.html {redirect_to home_path}
      else
        wants.html {render :action => 'new'}
      end
    end 
  end
  
  def show
    @feedback = Feedback.find(params[:id])
    render :layout => "admin"
  end
  
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to feedbacks_path
  end

  private 
  
  def allow_to 
    super :admin, :all => true
    super :non_user, :only => [:new, :create]
    super :user, :only => [:new, :create]
  end
  
end
