class InvitationsController < ApplicationController
  before_filter :show_panels
  before_filter :setup_user_profile
  
  def index
    redirect_to new_profile_invitation_path
  end

  def new
    @invitation = Invitation.new(:profile_id => @profile)
  end

  def create    
    respond_to do |format|
      format.html do
        @invites = []
        params[:invitation][:emails].split(%r{,\s*}).each do |e|
          e.gsub!(/\s*/,'') # Remove all spaces from the email address
          i = Invitation.find_or_initialize_by_email_and_profile_id(e,@profile.id)
          raise Exception.new(i.errors) if !i.valid?
          i.save
          @invites << i
        end
        raise Exception.new("No Emails found") if @invites.blank?
      end
    end
  rescue Exception => e
    flash.now[:error] = 'Seem like there was an error sending your invites'
    @invitation = Invitation.new(:emails => params[:invitation][:emails])  
    @error = e.to_s
    render :action => :new
  end

  private
  
  def setup_user_profile
    @profile = params[:profile_id].to_i == @p.id ? @p : Profile[params[:profile_id]]
    @user = params[:profile_id].to_i == @p.id ? @u : @profile.user
  end

  def show_panels
    @show_profile_side_panel = true
  end

  def allow_to
    super :owner, :all => true
    super :active_user, :all => true
  end

end
