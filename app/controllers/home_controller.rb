class HomeController < ApplicationController
  skip_before_filter :login_required	
  skip_filter :store_location, :only => [:show]
  #caches_page :show
  include HomeHelper
  def index
    blogs = Blog.public.all(:include => [:profile, :tags])
    polls = Poll.public.open_polls.all(:include => :profile)
    events = Event.all(:include => :profiles)
    @home_data = sorted_results(blogs,polls,events).paginate(:page => params[:page],:per_page => BLOGS_PER_PAGE)
    @blurb_image = Photo.blurb_images
    respond_to do |wants|
      wants.html
    end
  end

  def newest_members 
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end

  def latest_comments
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end


  def show
    if params[:page] == "tos"
      render :action => params[:page], :layout => false
    elsif params[:page] == 'credits'
      render :action => params[:page] , :layout=> "plain"
    else
      render :action => params[:page]
    end
  end
  
  def gallery
    when_fragment_expired(cache_name_flickr(params[:set_id],params[:page]),SITE_FLICKR_EXPIRE_TIME_MIN.minutes.from_now) do
      if params[:set_id]
        pics = flickr_images_by_photoset(params[:set_id]) # return nil if dosnt have any sets
        @pictures = pics
      else
        @pictures = unsets_flickr_pictures
      end
      respond_to do |wants|
        wants.html{render :partial => 'gallery', :object => @pictures}
      end
    end
  end
  
  private

  def allow_to 
    super :all, :all=>true
  end

end

class HomeMailer < ActionMailer::Base
  def mail(options)
    self.generic_mailer(options)
  end
end