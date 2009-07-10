class CreateMaass < ActiveRecord::Migration
  def self.up
  
    create_table "blogs", :force => true do |t|
      t.string   "title"
      t.text     "body"
      t.integer  "profile_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_sent",    :default => false
    end

    add_index "blogs", ["profile_id"], :name => "index_blogs_on_profile_id"

    create_table "comments", :force => true do |t|
      t.text     "comment"
      t.datetime "created_at",                          :null => false
      t.datetime "updated_at",                          :null => false
      t.integer  "profile_id"
      t.string   "commentable_type", :default => "",    :null => false
      t.integer  "commentable_id",                      :null => false
      t.integer  "is_denied",        :default => 0,     :null => false
      t.boolean  "is_reviewed",      :default => false
    end

    add_index "comments", ["profile_id"], :name => "index_comments_on_profile_id"
    add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"

    create_table "educations", :force => true do |t|
      t.integer  "profile_id"
      t.string   "highschool_name"
      t.string   "education_from_year"
      t.string   "education_to_year"
      t.string   "university"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "emails", :force => true do |t|
      t.string   "from"
      t.string   "to"
      t.integer  "last_send_attempt", :default => 0
      t.text     "mail"
      t.datetime "created_on"
    end

    create_table "events", :force => true do |t|
      t.datetime "start_date"
      t.datetime "end_date"
      t.string   "title"
      t.string   "place"
      t.string   "type"
      t.text     "description"
      t.string   "first_contact_person"
      t.integer  "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "second_contact_person"
      t.string   "third_contact_person"
      t.string   "fourth_contact_person"
      t.string   "fifth_contact_person"
    end

    create_table "feed_items", :force => true do |t|
      t.boolean  "include_comments", :default => false, :null => false
      t.boolean  "is_public",        :default => false, :null => false
      t.integer  "item_id"
      t.string   "item_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "feed_items", ["item_id", "item_type"], :name => "index_feed_items_on_item_id_and_item_type"

    create_table "feedbacks", :force => true do |t|
      t.string   "name"
      t.string   "email"
      t.string   "subject"
      t.text     "message"
      t.integer  "profile_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feeds", :force => true do |t|
      t.integer "profile_id"
      t.integer "feed_item_id"
    end

    add_index "feeds", ["profile_id", "feed_item_id"], :name => "index_feeds_on_profile_id_and_feed_item_id"

    create_table "friends", :force => true do |t|
      t.integer  "inviter_id"
      t.integer  "invited_id"
      t.integer  "status",     :default => 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "friends", ["inviter_id", "invited_id"], :name => "index_friends_on_inviter_id_and_invited_id", :unique => true
    add_index "friends", ["invited_id", "inviter_id"], :name => "index_friends_on_invited_id_and_inviter_id", :unique => true

    create_table "messages", :force => true do |t|
      t.string   "subject"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sender_id"
      t.integer  "receiver_id"
      t.boolean  "read",          :default => false, :null => false
      t.boolean  "sender_flag",   :default => true
      t.boolean  "receiver_flag", :default => true
    end

    add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
    add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"

    create_table "permissions", :force => true do |t|
      t.integer  "profile_id"
      t.string   "field"
      t.string   "permission", :default => "Friends"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "profiles", :force => true do |t|
      t.integer  "user_id"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "website"
      t.string   "blog"
      t.string   "flickr"
      t.text     "about_me"
      t.string   "aim_name"
      t.string   "gtalk_name"
      t.string   "ichat_name"
      t.string   "icon"
      t.string   "location"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "email"
      t.boolean  "is_active",                  :default => false
      t.string   "youtube_username"
      t.string   "flickr_username"
      t.string   "year"
      t.date     "date_of_birth"
      t.date     "anniversary_date"
      t.string   "relationship_status"
      t.string   "spouse_name"
      t.string   "maiden_name"
      t.string   "gender"
      t.text     "activities"
      t.string   "yahoo_name"
      t.string   "skype_name"
      t.string   "status_message"
      t.string   "occupation"
      t.string   "industry"
      t.string   "company_name"
      t.string   "company_website"
      t.text     "job_description"
      t.string   "address_line1"
      t.string   "address_line2"
      t.string   "postal_code"
      t.string   "city"
      t.string   "state"
      t.string   "country"
      t.string   "landline"
      t.string   "mobile"
      t.string   "professional_qualification"
      t.string   "default_permission",         :default => "Everyone"
    end

    add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

    create_table "sessions", :force => true do |t|
      t.string   "session_id"
      t.text     "data"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "student_checks", :force => true do |t|
      t.string   "name"
      t.string   "first_name"
      t.string   "middle_name"
      t.string   "last_name"
      t.date     "birth_date"
      t.string   "sex"
      t.string   "f_name"
      t.string   "m_name"
      t.string   "f_desg"
      t.string   "m_desg"
      t.string   "r_add1"
      t.string   "r_add2"
      t.string   "r_add3"
      t.string   "o_add1"
      t.string   "o_add2"
      t.string   "o_add3"
      t.string   "o_ph_no"
      t.string   "r_ph_no"
      t.string   "mobile"
      t.string   "enroll_no"
      t.string   "year"
      t.string   "roll_no"
      t.string   "classname"
      t.string   "house_name"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "e_mail_1"
      t.string   "e_mail_2"
    end

    create_table "users", :force => true do |t|
      t.string   "login"
      t.string   "crypted_password",            :limit => 40
      t.string   "salt",                        :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token"
      t.datetime "remember_token_expires_at"
      t.boolean  "is_admin"
      t.boolean  "can_send_messages",                         :default => true
      t.string   "time_zone",                                 :default => "UTC"
      t.string   "email_verification"
      t.boolean  "email_verified"
      t.date     "last_login_date"
      t.string   "first_referral_person_name"
      t.string   "first_referral_person_year"
      t.string   "second_referral_person_name"
      t.string   "second_referral_person_year"
      t.string   "third_referral_person_name"
      t.string   "third_referral_person_year"
      t.text     "additional_message"
      t.string   "requested_new_email"
    end

    add_index "users", ["login"], :name => "index_users_on_login"
  end

  def self.down
    drop_table :blogs
    drop_table :comments
    drop_table :educations
    drop_table :emails
    drop_table :events
    drop_table :feed_items
    drop_table :feedbacks
    drop_table :feeds
    drop_table :friends
    drop_table :messages
    drop_table :permissions
    drop_table :photos
    drop_table :profiles
    drop_table :sessions
    drop_table :student_checks
    drop_table :users

  end
end
