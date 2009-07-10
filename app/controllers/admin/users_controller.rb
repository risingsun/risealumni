class Admin::UsersController < ApplicationController
  cache_sweeper :profile_sweeper, :only => [:update]
  layout "admin"
  def index
    search_results
    render
  end
  
  def update
    @profile = Profile.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if @p == @profile
            #page << "message('You cannot deactivate or activate yourself!');"
          else
            @profile.toggle_status!
            ArNotifier.deliver_user_status(@profile) # Send the mail to user about the new status
            #page << "message('User has been marked as #{@profile.is_active ? 'active' : 'inactive'}');"
            page.replace_html @profile.dom_id('link'), (@profile.is_active ? 'Deactivate' : 'Activate')
          end
        end
      end
    end
  end
  
=begin
def destroy
    @profile = Profile.find(params[:id])
    respond_to do |wants|
      wants.js do
        render :update do |page|
          if @p == @profile
            page << "message('You cannot delete yourself!');"
          else
            @profile.user.destroy # Delete the user from the system
            @profile.destroy # we need to keep profile of tht user. as the previous working
            page << "message('User has been deleted');"
            page.replace_html @profile.dom_id("p_#{@profile.id}"), " "
          end
        end
      end
    end
  end

=end
  
  private
  
  def allow_to
    super :admin, :all => true
  end
  
end
