class Admin::EventsController < ApplicationController 
  
  layout "application"
  
  uses_tiny_mce(:options => {:theme => 'advanced',
      :theme_advanced_toolbar_location => "bottom",
      :theme_advanced_toolbar_align => "left",
      :theme_advanced_resizing => true,
      :theme_advanced_resize_horizontal => false,
      :paste_auto_cleanup_on_paste => true,
      :theme_advanced_buttons1 => %w{bold italic underline strikethrough separator justifyleft 
                                            justifycenter justifyright indent outdent separator bullist numlist 
                                            separator link unlink image undo redo code forecolor backcolor
                                            newdocument cleanup},
      :theme_advanced_buttons2 => %w{formatselect fontselect fontsizeselect},
      :theme_advanced_buttons3 => [],
      :plugins => %w{contextmenu paste}},
    :only => [:new, :edit])
  
  def index 
    @events = Event.paginate(:order => 'created_at DESC', :page => @page, :per_page => @per_page)
    if @events.blank?
      @event = Event.new
      render :action => 'new',:layout =>"admin"
      return
    end
    render :layout => "admin"
   end
    
  def new
    @event = Event.new
    render :layout => "admin"
  end
    
  def create
    @event = Event.new(params[:event])
    respond_to do |wants|
      if @event.save
        @event.set_organizer(@p)
        wants.html do
          flash[:notice] = 'Event was successfully created.'
          redirect_to admin_events_path  
        end
      else
        @uses_tiny_mce = true
        wants.html do
          flash[:notice] = 'Event was not successfully created.'
          render :action => "new" ,:layout => 'admin' 
        end
      end
    end
  end
  
  def show
    @event = Event.find(params[:id])
    @comments = @event.comments.paginate(:per_page => @per_page , :page => @page_no)
  end
    
  def edit
    @event =Event.find(params[:id])
    render :layout => "admin"
  end
    
  def update
    @event = Event.find(params[:id])
    respond_to do |wants|
      if @event.update_attributes(params[:event])
        wants.html do
          flash[:notice] = 'Event was successfully updated.'
          redirect_to admin_events_path 
        end
      else
        @uses_tiny_mce = true
        wants.html do
          flash[:notice] = 'Event was not successfully updated.'
          render :action => "edit",:layout => 'admin' 
        end
      end
    end 
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    respond_to do |wants|
      wants.html do 
        flash[:notice] = 'Event was successfully deleted.'
        redirect_to admin_events_path 
      end
    end
  end
  
  def send_event_mail
    @event = Event.find(params[:id])
    @profiles = Profile.find(:all, :conditions => {:is_active => true}) # TODO Can we use find_each 
    @profiles.each do|profile|
      ArNotifier.deliver_send_event_mail(profile,@event) if profile.wants_event_email_notification?
      Profile.admins.first.sent_messages.create(:subject => "[#{SITE_NAME} Events] Latest event", :body =>"#{@event.title}, #{@event.description}",
                                         :receiver => profile, :system_message => true) if profile.wants_event_message_notification?

    end
    flash[:notice] = 'Mail was successfully sent'
    redirect_to admin_events_path
  end
  
  def rsvp
    event = Event.find(params[:id])
    pe = ProfileEvent.find(:first,:conditions => {:event_id => event.id,:profile_id => @p.id})
    unless pe
      pe = ProfileEvent.create(:event_id => event.id,:profile_id => @p.id)
    end
    pe.update_attribute('role',params[:event_rsvp])unless pe.is_organizer?
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if params[:status]== 'home_page'
            page.replace_html "event_rsvp_#{event.id}", :partial => 'admin/events/event_response',:locals => {:event => event}
          else
            page.replace_html "event_rsvp_#{event.id}", :partial => 'admin/events/rsvp',:locals => {:event => event}
          end
        end
      end
    end
  end
  def attending_members
    @event = Event.find(params[:id])
    @results = @event.attending.paginate(:page => params[:page], :per_page => @per_page) 
    @title = "Attending"
    render :template => "shared/user_friends"
  end
  def not_attending_members
    @event = Event.find(params[:id])
    @results = @event.not_attending.paginate(:page => params[:page], :per_page => @per_page)
    @title = "Not Attending "
    render :template => "shared/user_friends"
  end
  def may_be_attending_members
    @event = Event.find(params[:id])
    @results = @event.may_be_attending.paginate(:page => params[:page], :per_page => @per_page)
    @title = "May be attending"
    render :template => "shared/user_friends"
  end
  
  private
  def allow_to
    super :admin, :all => true
    super :active_user, :only => [:show,:rsvp,:attending_members,
                                  :not_attending_members,:may_be_attending_members]
  end
  
end
