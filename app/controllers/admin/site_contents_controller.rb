class Admin::SiteContentsController < ApplicationController
  cache_sweeper :site_content_sweeper, :only => [:update]
  layout "admin"
  
  
  # GET /site_contents
  # GET /site_contents.xml
  def index
    @site_contents = SiteContent.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_contents }
    end
  end

  # GET /site_contents/1
  # GET /site_contents/1.xml
  def show
    @site_content = SiteContent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_content }
    end
  end

  # GET /site_contents/new
  # GET /site_contents/new.xml
  def new
    @site_content = SiteContent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_content }
    end
  end

  # GET /site_contents/1/edit
  def edit
    @site_content = SiteContent.find(params[:id])
  end

  # POST /site_contents
  # POST /site_contents.xml
  def create
    @site_content = SiteContent.new(params[:site_content])

    respond_to do |format|
      if @site_content.save
        flash[:notice] = 'SiteContent was successfully created.'
        format.html { redirect_to(admin_site_content_path(@site_content)) }
        format.xml  { render :xml => @site_content, :status => :created, :location => @site_content }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_contents/1
  # PUT /site_contents/1.xml
  def update
    @site_content = SiteContent.find(params[:id])

    respond_to do |format|
      if @site_content.update_attributes(params[:site_content])
        flash[:notice] = 'SiteContent was successfully updated.'
        format.html { redirect_to(admin_site_content_path(@site_content)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_content.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_contents/1
  # DELETE /site_contents/1.xml
  def destroy
    @site_content = SiteContent.find(params[:id])
    @site_content.destroy

    respond_to do |format|
      format.html { redirect_to(admin_site_contents_url) }
      format.xml  { head :ok }
    end
  end
    
  private
  def allow_to
    super :admin, :all => true
  end
end