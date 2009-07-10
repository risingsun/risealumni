class AccountsController < ApplicationController
  skip_before_filter :login_required, :except => :logout
  skip_after_filter :store_location
  #before_filter :check_email ,:only => [:signup]
  cache_sweeper :profile_sweeper, :only => [:confirmation_email]
  
  def login
    redirect_back_or_default(home_path) and return if @u
    @user = User.new
    return unless request.post?
    #plays double duty login/forgot (due to the ajax nature of the login/forgot form)
    if params[:new_password] 
      u = Profile.find_by_email(params[:profile][:email]).user rescue nil
      if u.nil? 
        flash.now[:error] = "Could not find that email address. Try again."
        render :action => 'forgot_password'
        return
      else
        @pass = u.forgot_password! #must be @ variable for function tests
        AccountMailer.deliver_forgot_password(u.profile.email, u.full_name, u.login, @pass)
        flash.now[:notice] = "A new password has been mailed to you."
      end
    else
      params[:login] ||= params[:user][:login] if params[:user]
      params[:password] ||= params[:user][:password] if params[:user]
      self.user = User.authenticate(params[:login], params[:password])
      if @u && !@u.email_verified
        reset_session
        flash[:error] = 'Your email address has not yet been confirmed.'
        return false
      elsif @u && @u.email_verified
        #@u.record_login! # Records the time when the user is suucessfully loggedin
        #@u.save!
        remember_me if params[:user][:remember_me] == "1"
        flash[:notice] = "Hello #{@u.full_name}"
        redirect_back_or_default profile_url(@u.profile)
      else
        flash.now[:error] = "Uh-oh, login didn't work. Do you have caps locks on? Try it again."
      end
    end
  end

  def logout
    cookies[:auth_token] = {:expires => Time.now-1.day, :value => "" }
    session[:user] = nil
    session[:return_to] = nil
    clear_facebook_session_information
    clear_fb_cookies!
    flash[:notice] = "You have been logged out."
    redirect_to '/'
  end

  def signup
    redirect_back_or_default(home_path) and return if @u
    @user = User.new
    @profile = @user.build_profile
    session[:show_referral_form] = nil unless request.xhr? # need to nill the session which maintains the step two of signup process
    unless request.xhr?
      if (params[:fb_user] && facebook_user)
        @f_user = facebook_user
        @user.attributes = {:facebook_uid => @f_user.uid,:email_verified => true,:email_verification => nil}
        @profile.attributes ={:first_name => @f_user.first_name,
          :last_name => @f_user.last_name, :gender => @f_user.sex.titleize}
        return
      elsif params[:fb_user] && facebook_user.nil?
        redirect_to home_url and  return 
      else
        return
      end
    end
    u = User.new
    u.terms_of_service = params[:user][:terms_of_service]
    u.login = params[:user][:login]
    u.password = params[:user][:password]
    u.password_confirmation = params[:user][:password_confirmation]
    if @production
      u.captcha = params[:user][:captcha]
      u.captcha_answer = params[:user][:captcha_answer]
    end
    u.generate_confirmation_hash!
    if u.update_attributes(params[:user])
      if u.is_facebook_user?
        respond_to do |wants|
          wants.js do
            if u.profile.activate!
              self.user = u
              flash[:notice] = "Hello #{@u.full_name}"
              render :update do |page|
                page.redirect_to profile_path(@u.profile)
              end
            else
              reset_session
              flash[:notice] = "We're sorry but it seems that there was a problem activating your profile. Please contact the administrators to resolve the issue."
              render :update do |page|
                page.redirect_to home_path
              end
            end
          end
        end
      else
        AccountMailer.deliver_signup(u) unless u.is_facebook_user?
        reset_session
        @user = u
        render :update do |page|
          page.replace_html "main_container", :partial => "thanks"
        end
      end
    elsif u.errors[:references]
      session[:show_referral_form] = true
      @user = u
      @profile = u.profile
      @user.errors.add(:captcha, "can't be blank")
      render :update do |page|
        page.replace_html "main_container", :partial => "signup_form"
        page[:user_form].hide
        page[:tos].hide
        page[:referral_form].show
        page.replace_html "referral_error", :inline => @user.errors[:references] if @user.errors[:references]
        page << "jq('#user_captcha').val('');"
      end
    else
      @user = u
      @profile = u.profile
      @facebook_uid = params[:user][:facebook_uid]
      params[:user][:captcha] = params[:user][:password] = params[:user][:password_confirmation] = ''
      render :update do |page|
        page.replace_html "main_container", :partial => "signup_form"
        page[:user_form].hide  if session[:show_referral_form]
        page[:referral_form].show if session[:show_referral_form]
        page.replace_html "referral_error", :inline => " "
        page << "jq('#user_captcha').val('');"
      end
    end
  end
  
  def forgot_password
  end

  def confirmation_email
    @u = User.find(params[:user_id]) rescue nil
    if @u && @u.email_verified
      reset_session
      flash[:notice] = "Your email is already confirmed by us. Please login to continue."
      redirect_to login_path
      return true
    end
    if @u && @u.match_confirmation?(params[:hash])
      @u.confirm_email!
      @u.profile.activate!
      if @u.save
        AccountMailer.deliver_email_confirmed_by_user(@u) unless @u.profile.is_active
        reset_session
        flash[:notice] = "Thanks your email is confirmed by us. Please login to continue"
        redirect_to login_path
      else
        reset_session
        flash[:notice] = "We're sorry but it seems that there was a problem activating your profile. Please contact the administrators to resolve the issue."
        redirect_to home_path
      end
    else
      reset_session
      flash[:notice] = "We're sorry but it seems that the confirmation did not go thru. You may have provided an expired key."
      redirect_to login_path
    end
  end
  
  def check_email
    p = Profile.find_by_email(params[:email])
    render :update do |page|
      if p && p.user.email_verified
        page.replace_html "email_msg", :inline => "<span id='email_failure' name='email_failure' class='error'>This email has already been taken</span>"
      else
        page.replace_html "email_msg", :inline => "<span id='email_success' name='email_success' class='sys_message'>This email is available</span>"
      end
    end
  end
  
  def check_login
    user = User.find_by_login(params[:login])
    render :update do |page|
      if user# && user.email_verified
        page.replace_html "login_msg", :inline => "<span id='login_failure' name='login_failure' class='error'>This login has already been taken</span>"
      else
        page.replace_html "login_msg", :inline => "<span id='login_success' name='login_success' class='sys_message'>This login is available</span>"
      end
    end
  end

  protected

  def remember_me
    self.user.remember_me!
    cookies[:auth_token] = {
      :value => self.user.remember_token ,
      :expires => self.user.remember_token_expires_at
    }
  end

  def allow_to
    super :all, :all=>true
  end
end
