class MessagesController < ApplicationController
  before_filter :can_send, :only => :create
  before_filter :setup, :except => [:delete_messages]
  
  cache_sweeper :messages_sweeper, :only => [:create,:destroy,:delete_messages,:show]

  def index
    @message = Message.new
    @to_list = @p.friends
    if @p.received_messages.empty? && @p.sent_messages.empty? && @p == @profile 
      if @p.can_send_messages && @p.has_network?
        flash[:notice] = 'You have no mail in your inbox.  Try sending a message to someone.'
        @to_list = (@p.followers + @p.friends + @p.followings)
        #@to_list = (@p.friends)
        redirect_to new_profile_message_path(@p) and return
      else
        flash[:notice] = "You cannot send messages"
      end
    end
  end
  
  def create
    @message = @p.sent_messages.create(params[:message]) 
    respond_to do |wants|
      if @message.new_record?
        flash[:notice] = @message.errors.to_s
        wants.html do
          redirect_to new_profile_message_path(@p)
        end
      else
        wants.html do
          ArNotifier.deliver_message_send(@message,@p) if @profile.wants_message_email_notification?
          flash[:notice] = "Your Message has been sent."
          redirect_to :action => :index
        end
      end
    end
  end
  
  def new
    unless @p.can_send_messages
      redirect_to :action => :index and return
    end
    unless @p.has_network?
      redirect_to :action => :index and return
    end
    @message = Message.new
    @to_list = (@p.followers + @p.friends + @p.followings)
    render
  end
  
  def direct_message
    @to_list = [Profile.find(params[:profile_id])]
    render :action => "new"
  end
  
  def reply_message
    @message = Message.find(params[:id])
    @to_list = [@message.sender]
    render :action => "new"
  end
  
  def sent
    @message = Message.new
    @to_list = @p.friends
  end
  
  def show    
    @msg = Message.find(params[:id])
    if @msg.check_view_permission(@p)
      if @msg.in? @p.received_messages # Sets the Message as read from the inbox only.
        @msg.read = true
        @msg.save!
      end
      @message = @p.sent_messages.find params[:id] rescue nil
      @message ||= @p.received_messages.find params[:id] rescue nil
      @to_list = [@message.sender]
    else
      flash[:error] = 'It looks like you don\'t have permission to view that page.'
      redirect_back_or_default(profile_messages_path(@p))
    end
  end
  
  def destroy
    message = Message.find(params[:id])
    message.delete_message(@p.id)
    redirect_back_or_default(profile_messages_path(@p))
  end
  
  def delete_messages
    params[:check].each do |ch|
      message = Message.find(ch)
      message.delete_message(@p.id)
    end
    redirect_back_or_default(profile_messages_path(@p)) 
  end

  protected

  def allow_to
    super :owner, :all => true
    super :active_user, :only => [:direct_message]
  end
  
  def setup
    @profile = Profile[params[:profile_id]]
    @user = @profile.user
  end
  
  def can_send
    render :update do |page|
      page.alert "Sorry, you can't send messages. (Cuz you sux.)"
    end unless @p.can_send_messages
  end
end
