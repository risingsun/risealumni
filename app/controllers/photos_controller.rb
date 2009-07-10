class PhotosController < ApplicationController
  layout "admin"
  # GET /photos
  # GET /photos.xml
  before_filter :setup,:except => [:create,:update]
  def index
    if @blurb_image ==  "true"
      @photos = Photo.blurb_images.paginate(:order => 'created_at DESC', :page => @page, :per_page => @per_page)
    else
      @photos = Photo.images.paginate(:order => 'created_at DESC', :page => @page, :per_page => @per_page)
    end
    respond_to do |format|
      if @photos.blank?
        @photo = Photo.new
        @photo.set_as_blurb = @blurb_image
        format.html { render :action => 'new' }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      else
        format.html
        format.xml  { render :xml => @photos }
      end
    end
  end

  # GET /photos/new
  # GET /photos/new.xml
  def new
    @photo = Photo.new
    @photo.set_as_blurb = @blurb_image
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @photo }
    end
  end


  # POST /photos
  # POST /photos.xml
  def create
    @photo = Photo.new(params[:photo])
    @photo.profile = @p
    @blurb_image = params[:photo][:set_as_blurb]
    respond_to do |format|
      if @photo.save
        flash[:notice] = 'Image was successfully created.'
        format.html { redirect_to(photos_path.add_param(:blurb_image => @blurb_image)) }
        format.xml  { render :xml => @photo, :status => :created, :location => @photo }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end
  def edit
    @photo = Photo.find(params[:id])
  end


  def update
    @photo = Photo.find params[:id]
    @blurb_image = @photo.try(:set_as_blurb)
    if @photo.update_attributes params[:photo]
      flash[:notice] = 'Image was successfully updated.'
      redirect_to(photos_path.add_param(:blurb_image => @blurb_image))
    else
      flash[:notice] = 'Image was not successfully updated.'
      render :action => "edit"
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.xml
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy

    respond_to do |format|
      format.html { redirect_to(photos_path.add_param(:blurb_image => @blurb_image)) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def setup
    @blurb_image = params[:blurb_image]
  end
  
  def allow_to
    super :admin, :all => true
  end
end
