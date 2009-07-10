class AnnouncementsController < ApplicationController

  layout 'admin'

  # GET /announcements
  # GET /announcements.xml
  def index
    @announcements = Announcement.find(:all, :order => 'starts_at desc')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @announcements }
    end
  end

  # GET /announcements/new
  # GET /announcements/new.xml
  def new
    @announcement = Announcement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @announcement }
    end
  end

  # GET /announcements/1/edit
  def edit
    @announcement = Announcement.find(params[:id])
  end

  # POST /announcements
  # POST /announcements.xml
  def create
    @announcement = Announcement.new(params[:announcement])

    respond_to do |format|
      if @announcement.save
        flash[:notice] = 'Announcement was successfully created.'
        format.html { redirect_to announcements_path }
        format.xml  { render :xml => @announcement, :status => :created, :location => @announcement }
      else
        format.html do
          flash[:notice] = 'Announcement was not Successfully created'
          render :action => "new" 
        end
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /announcements/1
  # PUT /announcements/1.xml
  def update
    @announcement = Announcement.find(params[:id])

    respond_to do |format|
      if @announcement.update_attributes(params[:announcement])
        flash[:notice] = 'Announcement was successfully updated.'
        format.html { redirect_to announcements_path }
        format.xml  { head :ok }
      else
        format.html do
          flash[:notice] = 'Announcement was not successfully updated'
          render :action => "edit" 
        end
        format.xml  { render :xml => @announcement.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /announcements/1
  # DELETE /announcements/1.xml
  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = 'Announcement has been successfully delected'
        redirect_to announcements_path 
      end
      format.xml  { head :ok }
    end
  end
  
  private

  def allow_to
    super :admin, :all => true
  end

end
