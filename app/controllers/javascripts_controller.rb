class JavascriptsController < ApplicationController
  skip_before_filter :login_required	
  def hide_announcement
    session[:announcement_hide_time] = Time.now.utc
  end
  
  def allow_to
    super :all, :all=>true
  end
end
