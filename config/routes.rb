ActionController::Routing::Routes.draw do |map|
  map.resources :photos
  map.resources :fb_connect,:collection =>{:connect => :get}

  map.resources :votes

  map.resources :announcements

  map.namespace :admin do |a|
    a.resources :users, :collection => {:search => :post}
    a.resources :events,
                :member => {:send_event_mail => :post,:attending_members => :get,:not_attending_members => :get,:may_be_attending_members=> :get},
                :has_many => [:comments]
    a.resources :site_contents
    a.resources :preferences, :member => {:edit_preferences => :get,
                                          :delete_title => :delete,
                                          :delete_house_name => :delete,
                                          :new_preference => :get
                                         }, 
                              :collection => { :update_preferences => :put, 
                                                :new_title => :get, :add_title => :put,
                                                :new_house_name => :get,
                                                :add_house_name => :put,
                                                :edit_title => :get,
                                                :update_title => :put,
                                                :edit_house_name => :get,
                                                :update_house_name => :put
                                                }
                           
  end
  map.show_event '/show/:id', :controller => 'admin/events', :action => 'show', :method => 'get' 
  map.rsvp '/rsvp/:id/:status', :controller => 'admin/events', :action => 'rsvp'
  map.resources :profiles, 
    :member => {:delete_icon => :post,
    :set_permissions => :get,
    :status_update => :post,
    :edit_account => :get,
    :batch_mates => :get,
    :network => :get, 
    :followers => :get, 
    :followings => :get, 
    :notification_control => :post},
    :collection => {:search => :get, :batch_details => :get}, 
    :has_many => [:friends, :blogs, :comments, :feed_items] do |profile|
    profile.resources :messages, 
      :collection => {:delete_messages => :post, 
      :sent => :get, 
      :direct_message => :get},
      :member => {:reply_message => :get}
    profile.resources :polls,
      :member => {:poll_close => :get}
    profile.resources :invitations
  end

  map.delete_comment '/delete_comment/:id', :controller => 'comments', :action => 'destroy'
  map.resources :blogs,:collection => {:auto_complete_for_blog_tag_list => :get} do |blog|
    blog.resources :comments, :collection => {:create_blog_comment => :post}
  end
  
  map.blog_archive '/blog_archive/:month/:year', :controller => 'blogs', :action => 'blog_archive', :method => :get
  map.search_blog '/search_blog', :controller => 'blogs', :action => 'search_blog', :method => :get
  map.blogs_by_tag '/blogs_by_tag/:tag_id', :controller => 'blogs', :action => 'blogs_by_tag', :method => :get
  
  map.resources :forums, :collection => {:update_positions => :post} do |forum|
    forum.resources :topics, :controller => :forum_topics do |topic|
      topic.resources :posts, :controller => :forum_posts
    end
  end


  map.with_options(:controller => 'accounts') do |accounts|
    accounts.login   "/login",   :action => 'login'
    accounts.logout  "/logout",  :action => 'logout'
    accounts.signup  "/signup",  :action => 'signup'
    accounts.forgot_password  "/forgot_password",  :action => 'forgot_password'
    accounts.check_email '/accounts/check_email/', :action => 'check_email'
    accounts.check_login '/accounts/check_login/', :action => 'check_login'
  end
  
  map.root :controller => 'home'
  map.with_options(:controller => 'home') do |home|
    home.home '/', :action => 'index'
    home.latest_comments '/latest_comments.rss', :action => 'latest_comments', :format=>'rss'
    home.newest_members '/newest_members.rss', :action => 'newest_members', :format=>'rss'
    home.set_gallery '/gallery/set/:set_id', :action => 'gallery'
    home.gallery '/gallery', :action => 'gallery'
    home.page ':page', :action => 'show', :page => /about_us|contact|history|members|academics|contact|credits|tos/
  end
  
  map.resources :feedbacks
  
  map.new_feedback '/feedback', :controller => 'feedbacks', :action => 'new'
  
  map.confirm_email '/ce/:hash/:user_id', :controller => 'accounts', :action => 'confirmation_email'

  map.update_email '/ue/:hash/:profile_id', :controller => 'profiles', :action => 'update_email'
  
  map.with_options(:controller => 'admin/home') do |admin_home|
    admin_home.admin_index '/admin/home/index', :action => "index"
    admin_home.admin_blogs '/admin/home/blogs', :action => 'admin_blogs'
    admin_home.send_admin_blog '/admin/home/send_blog/:id', :action => "send_blog"
    admin_home.admin_home '/admin/home/admin_home', :action => 'admin_home'
    admin_home.refresh_cache '/admin/home/refresh_cache', :action => "refresh_cache", :method => :delete
    admin_home.google_map_locations '/admin/home/google_map_locations', :action => "google_map_locations", :method => :get
  end
  
  map.resources :events, :collection => {:alumni_friends => :get}
  map.resources :student_checks, :collection => {:send_bulk_invite => :post, :view_year_students => :get}, :member => {:send_invite => :post}
  map.with_options(:controller => 'javascripts')  do |javascript|
    javascript.hide_announcement 'javascripts/hide_announcement', :action => 'hide_announcement', :format => 'js'  
  end
 
end
