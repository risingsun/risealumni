class FbConnectController < ApplicationController
  skip_before_filter :login_required

  def new
  end


  def connect
    begin
      secure_with_token!
      session[:facebook_session] = facebook_session
      logger.debug "facebook session in connect: #{facebook_session.inspect}"
      if facebook_user
        if logged_in? 
          if @u.update_attributes(:facebook_uid => facebook_user.uid)
            flash[:error] = 'Sucessfully logged in facebook.'
            redirect_to profile_path(@u.profile) and return
          else
            flash[:error] = 'Facebook account already exist.'
            return redirect_to("/")
          end
        else
          self.user = User.find_by_facebook_uid(facebook_user.uid)
          if @u && !@u.email_verified
            reset_session
            flash[:error] = 'Your email address has not yet been confirmed.'
            return redirect_back_or_default(home_path)
          elsif @u && @u.email_verified
            flash[:notice] = "Hello #{@u.full_name}"
            return redirect_back_or_default(profile_path(@u.profile))
          else
            return redirect_to(signup_path.add_param({:fb_user => true}))
          end
        end
      end
    rescue Facebooker::Session::MissingOrInvalidParameter => e
      return redirect_to("/")
    end
    return redirect_to("/")
  end




  def allow_to
    super :all, :all=>true
  end
end
