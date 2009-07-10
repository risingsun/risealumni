class VotesController < ApplicationController
 
  def create
    if params[:poll_option]
      @option = PollOption.find(params[:poll_option])
      @vote = @p.poll_responses.new(:poll_option => @option, :poll => @option.poll)
      @vote.save
      respond_to do |format|
        format.js
      end
    else
      render :update do |page|
          page.replace_html "poll_errors", :inline => "<div id='poll_messages' name='login_failure' class='error_msg'>Please select a option</div>"
        end
    end
  end

  private

  def allow_to
    super :active_user, :all => true
  end

end
