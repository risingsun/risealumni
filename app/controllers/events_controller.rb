class EventsController < ApplicationController
  layout "admin"
  
  def index
    respond_to do |format|
      format.ics do
        @birthdays = Profile.find(:all,:conditions => 'date_of_birth is not null')
        @anniversaries = Profile.find(:all, :conditions => 'anniversary_date is not null')
        @calendar = Icalendar::Calendar.new
        @birthdays.each { |e| @calendar.add e.to_ical_birthday_event }
        @anniversaries.each { |e| @calendar.add e.to_ical_anniversary_event }
        @calendar.publish
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render :layout=> false, :text => @calendar.to_ical
      end
      format.html 
    end
  end
  
  def alumni_friends
    @friends = @p.all_friends
    respond_to do |format|
      format.ics do
        @calendar = Icalendar::Calendar.new
        @friends.each do |e|
          if e.can_see_field('anniversary_date', @p)
            aevent = e.to_ical_anniversary_event
            @calendar.add aevent if aevent
          end
          if e.can_see_field('date_of_birth', @p)
            bevent = e.to_ical_birthday_event
            @calendar.add bevent if bevent
          end
        end
        @calendar.publish
        headers['Content-Type'] = "text/calendar; charset=UTF-8"
        render :layout=> false, :text => @calendar.to_ical
      end
    end
  end
  
  private
  
  def allow_to
    super :admin, :all => true
    super :active_user, :only => [:alumni_friends]
  end

end
