module InvitationsHelper
  def msg_profile_block
    str = ""
    @invites.each do |i|
      str += "<p>" +
        case i.status
        when :already_existing
          "Profile with email #{i.email} already exists, Check out #{link_to i.profile.full_name, profile_path(i.profile)}"
        when :reinvited
          "Friend with #{i.email} has been reinvited"
        when :already_invited
          "Friend with #{i.email} has already been invited recently"
        else
          "Friend with #{i.email} invited on your behalf."
        end + "</p>"
    end
    str
  end

  def remote_image_submit_tag(source,options)
    options[:with] ||= 'Form.serialize(this.form)'  
    options[:html] ||= {}
    options[:html][:type] = 'image'
    options[:html][:onclick] = "#{remote_function(options)}; return false;"
    options[:html][:src] = image_path(source)
    tag("input", options[:html], false)
  end

end
