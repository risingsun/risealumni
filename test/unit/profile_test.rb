require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase

  context 'A Profile instance' do
    should_belong_to :user
    should_have_many :friendships
    should_have_many :friends,   :through     => :friendships
    should_have_many :follower_friends
    should_have_many :following_friends
    should_have_many :followers, :through => :follower_friends
    should_have_many :followings, :through => :following_friends
    should_have_many :comments, :blogs
    #should_protect_attributes :is_active

    should_ensure_length_in_range :email, 3..100, :short_message => 'does not look like an email address.', :long_message => 'does not look like an email address.'
    should_allow_values_for :email, 'a@x.com', 'de.veloper@example.com', :message => 'does not look like an email address.'
    should_not_allow_values_for :email, 'example.com', '@example.com', 'developer@example', 'developer', :message => 'does not look like an email address.'
    should_require_attributes :first_name, :last_name, :group, :gender
    should_have_one :student_check, :notification_control
    should_have_many :profile_events
    should_have_many :events,:organizing,
                   :events_attending,:events_not_attending,
                   :events_may_be_attending, :through => :profile_events
  end


  context 'profiles(:user)' do
    should 'be friends with profiles(:user2)' do
      assert profiles(:user).friend_of?( profiles(:user2) )
      assert profiles(:user2).friend_of?( profiles(:user) )
    end

    should 'be following profiles(:user4)' do
      assert profiles(:user).following?( profiles(:user4) ) # need to use activate profiles.
      assert profiles(:user4).followed_by?( profiles(:user) )
    end
    
  end

  should "prefix with http" do
    p = profiles(:user)
    assert p.website.nil?
    assert p.website = 'lovdbyless.com'
    assert p.save
    assert_equal 'http://lovdbyless.com', p.reload.website
  end

  should 'check default status' do
    p = profiles(:user)
    assert p.default_status?
  end
  
  should "prefix with http4" do
    p = profiles(:user)
    assert p.website.nil?
    assert p.website = ''
    assert p.save
    assert_equal '', p.reload.website
  end


  should "prefix with http2" do
    p = profiles(:user)
    assert p.blog.nil?
    assert p.blog = 'lovdbyless.com'
    assert p.save
    assert_equal 'http://lovdbyless.com', p.reload.blog
  end


  should "prefix with http3" do
    p = profiles(:user)
    assert p.flickr.nil?
    assert p.flickr = 'lovdbyless.com'
    assert p.save
    assert_equal 'http://lovdbyless.com', p.reload.flickr
  end

  should "have wall with user2" do
    assert profiles(:user).has_wall_with(profiles(:user2))
    assert !profiles(:user).has_wall_with(profiles(:user6))
  end

  should "not have wall with user3" do
    assert !profiles(:user).has_wall_with(profiles(:user3))
  end

  def test_associations
    _test_associations
  end

  
  
  should "provide education details" do
    assert_not_nil profiles(:user).education_details
    assert_nil profiles(:user3).education_details

    assert_match  educations(:education).highschool_name,(profiles(:user).education_details)[0]
    assert_match  educations(:education).university,(profiles(:user).education_details)[1]
  end

  should "search all email confirmed user" do
    assert_not_nil profiles(:admin).search
  end

  should "search active user" do
    assert_not_nil profiles(:user).search
  end
  
  should "search by keyword for name" do
    p = profiles(:user)
    assert_not_nil p.search_by_keyword("name","De")
  end
  
  should "search by keyword for location" do
    p = profiles(:user4)
    assert_not_nil p.search_by_keyword("location","jaipur")
  end
  
  should "search by keyword for blood group" do
    p = profiles(:user)
    assert_not_nil p.search_by_keyword("blood_group","O-")
  end
  
  should "search by keyword for group" do
    p = profiles(:user)
    assert_not_nil p.search_by_keyword("group","2006")
  end
  
  should "search by keyword for contact" do
    p = profiles(:user)
    assert_not_nil p.search_by_keyword("contact","9352262626")
  end
  
    should "check active status" do
    p = profiles(:user)
    assert p.status
    assert_equal "activated",p.status
  end
  
  should "check deactive status" do
    p = profiles(:inactive)
    assert p.status
    assert_equal "deactivated",p.status
  end
  
  should 'check status if user status is active' do
    p = profiles(:user)
    assert p.status_check
    assert_equal 'active activated', p.status_check
  end
  
  should 'check status if user status is deactive' do
    p = profiles(:inactive)
    assert p.status_check
    assert_equal 'deactive deactivated', p.status_check
  end
 
  should 'test f' do
    p = profiles(:user2)
    assert p.f
    assert_equal 'John Mathew ...', p.f
  end

  should 'test f if title name not needed in full name' do
    p = profiles(:user2)
    assert p.f(15, :is_long => false)
    assert_equal 'John Mathew ...', p.f(15, :is_long => false)
  end

  should 'test f if short name needed' do
    p = profiles(:user2)
    assert p.f(15, {:is_short => true})
    assert_equal 'John Jones', p.f(15, :is_short => true)
  end
    
  should 'test f if full name required without title' do
    p = profiles(:user2)
    assert p.f
    assert_equal 'John Mathew ...', p.f
  end
 
  should 'test f if title is required in full name' do
    p = profiles(:user2)
    assert p.f(15, {:is_long => true})
    assert_equal 'Mr. John Mat...', p.f(15, {:is_long => true})
  end
   
  should 'test f if middle name required' do
    p = profiles(:user2)
    assert p.f(15, {:is_short => false})
    assert_equal 'John Mathew ...', p.f(15, {:is_short => false})
  end
  
  should "can see permissions" do
    u = users(:user2)
    p = profiles(:user)
    permission3 = permissions(:permission3)
    assert !p.can_see_field(permission3.field, u.profile)
  end
  
  should "find bdays" do
    assert_not_nil Profile.today_birthday
  end
  
  should "find anniversary" do
    assert_not_nil Profile.today_anniversary
  end

  should 'is not status message' do
    p = profiles(:user2)
    assert_not_nil p.status_message
  end
  
  should 'is status message' do
    p = profiles(:user4)
    assert_not_nil p.status_message
  end
  
  should 'featured profile' do
    assert_not_nil Profile.todays_featured_profile
  end
  
  should 'featured' do
    assert_not_nil Profile.featured
  end
  
  should 'new members' do
    assert_not_nil Profile.new_members
  end
  
  should "call param" do
    f = profiles(:user)
    assert_not_nil f.to_param
  end
  
  should 'has_network' do
    f = profiles(:user)
    assert_not_nil f.has_network?
    assert f.has_network?
  end
  
  should 'no data' do
    f = profiles(:user)
    assert_not_nil f.no_data?
    assert f.no_data?
  end
  
  should 'check activate status' do
    p = profiles(:user)
    assert_not_nil p.activate!
  end
  
  should 'check inactive status' do
    p = profiles(:user)
    assert_not_nil p.deactivate!
  end
  
  should 'toggle status' do
    p = profiles(:user)
    assert p.toggle_status!
  end
  
  should 'profile permissions' do
    p = profiles(:user)
    assert_not_nil p.profile_permissions
  end
  
  should 'check db permission' do
    p = profiles(:user)
    assert p.db_permissions  
  end
  
  should 'check field permissions' do
    p =  profiles(:user)
    assert p.field_permissions
  end
  
  should 'check active profiles' do
    assert Profile.active_profiles
  end
  
  should 'user can send messages' do
    p = profiles(:user)
    assert_not_nil p.can_send_messages
  end
  
  should 'find admins' do
    assert_not_nil Profile.admins
  end
  
  should 'check admin emails' do
    assert_not_nil Profile.admin_emails
  end
  
  should 'if location is blank' do
    p = profiles(:user)
    assert_not_nil p.location
    assert_equal 'Nowhere', p.location
  end
  
  should 'if location' do
    p = profiles(:user4)
    assert_not_nil p.location
    assert_equal 'jaipur', p.location
  end
  
  should 'check gender' do
    p = profiles(:user)
    assert_not_nil p.gender_str
  end

  should 'check gender if already in downcase' do
    p = Profile.create(:first_name => 'anurag', :last_name => 'saxena', :group => 2006, :gender => 'male', :email => 'anuraag.jpr@gmail.com')
    assert_not_nil p.gender_str
  end
  
  
  should 'check batch mates' do
    p = profiles(:user)
    assert_not_nil p.batch_mates(:per_page => 1, :page => 1)
  end
  
  should 'date of birth before type cast' do
    p = profiles(:user)
    assert_not_nil p.date_of_birth_before_type_cast
    assert_not_equal p.date_of_birth_before_type_cast, [p.date_of_birth]
    assert_equal "31 Dec 1985", p.date_of_birth_before_type_cast
  end
  
  should 'anniversay date before type cast' do
    p = profiles(:user)
    assert_not_nil p.anniversary_date_before_type_cast
    assert_not_equal p.anniversary_date_before_type_cast, [p.anniversary_date]
    assert_equal "22 May 2008", p.anniversary_date_before_type_cast
  end
  
  should 'check date of birth format' do
    p = profiles(:user)
    assert_not_nil p.date_of_birth_formatted
    assert_not_equal p.date_of_birth_formatted, [p.date_of_birth]
    assert_equal "31 Dec 1985", p.date_of_birth_formatted
  end
  
  should 'check anniversary date format' do
    p = profiles(:user)
    assert_not_nil p.anniversary_date_formatted
    assert_not_equal p.anniversary_date_formatted, [p.anniversary_date]
    assert_equal "22 May 2008", p.anniversary_date_formatted
  end
  
  should 'test batch details' do
    p = Profile.batch_details(2006, :page => 1, :per_page => 1)
    assert_not_nil p
  end
   
  should 'test full name' do
    p = profiles(:user)
    assert_not_nil p.full_name
    assert_equal 'De Veloper', p.full_name
  end
  
  should 'test recent  for yesterday' do
    profiles = Profile.recent(Date.today-1.days)
    assert profiles.blank?
  end
  should 'test recent  for today' do
    profiles = Profile.recent(Date.today)
    assert !profiles.blank?
  end
  should 'test full name if using spaces before and after first name and last name' do
    p = Profile.create(:first_name => ' anurag', :last_name => 'saxena ', :gender => 'male', :email => 'anuraag.jpr@gmail.com')
    assert_equal ' Anurag Saxena ', p.full_name
    assert p.full_name
  end
  
  should 'test full name if first name and last name is nil' do
    p = Profile.create(:first_name => nil, :last_name => nil, :gender => 'male', :email => 'anuraag.jpr@gmail.com')
    assert_not_nil p.full_name
  end
  
  should 'test full name if invalid first name or last name' do
    p =  Profile.create(:first_name => "a'rag", :last_name => "s'na", :gender => 'male', :email => 'anuraag.jpr@gmail.com')
    assert_not_nil p.full_name
  end
  
  should 'test full name including title' do
    p = profiles(:user2)
    assert p.full_name(:is_long => true)
    assert_equal 'Mr. John Mathew Jones', p.full_name(:is_long => true)
  end
  
  should 'test full name if passing false value for is long' do
    p = profiles(:user2)
    assert p.full_name(:is_long => false)
    assert_equal 'John Mathew Jones', p.full_name(:is_long => false)
  end
  
  should 'full name should return first name middle name and last name' do
    p = profiles(:user2)
    assert p.full_name
    assert_equal 'John Mathew Jones', p.full_name
  end
  
  should 'test full name if need short name' do
    p = profiles(:user2)
    assert p.full_name(:is_short => true)
    assert_equal 'John Jones', p.full_name(:is_short => true)
  end
  
  should 'test full name if passing false value for is short' do
    p = profiles(:user2)
    assert p.full_name(:is_short => false)
    assert_equal 'John Mathew Jones', p.full_name(:is_short => false)
  end
   
  should 'check default location' do
    p = Profile.create(:first_name => "a'rag", :last_name => "s'na", :gender => 'male', :email => 'anuraag.jpr@gmail.com', :location => nil)
    assert p.default_location?
    assert_equal 'Nowhere', p.location
  end
 
  should 'check default location if location given' do
    p = Profile.create(:first_name => "a'rag", :last_name => "s'na", :gender => 'male', :email => 'anuraag.jpr@gmail.com', :location => 'jaipur')
    assert p.default_status?
    assert_equal 'jaipur', p.location
  end
  
  should 'test extra details' do
    p = Profile.create(:first_name => 'anurag', :last_name => 'saxena', :gender => 'male', :email => 'abc@gmail.com',
      :group => 2006, :date_of_birth => '2008-05-22', :anniversary_date => '2008-05-22', :relationship_status => 'married' )
    assert_not_nil p.extra_details
  end
  
  should 'test extra details if values are nil' do
    p = Profile.create(:first_name => nil, :last_name => nil, :gender => nil, :email => nil,
      :group => nil, :date_of_birth => nil, :anniversary_date => nil, :relationship_status => nil)
    assert_not_nil p.extra_details
    assert !p.save
  end
  
  should 'test address details' do
    p = Profile.create(:first_name => 'anurag', :last_name => 'saxena', :gender => 'male', :email => 'abc@gmail.com',
      :group => 2006, :address_line1 => '61-b, civil lines', :address_line2 => '131, krishna vihar', :postal_code => 321001,
      :city => 'jaipur', :state => 'rajasthan', :country => 'india', :landline => 0141-2503026, :mobile => 9928372445)
    assert_not_nil p.address_details
    assert p.save
  end
  
  should 'test address details if some values are nil' do
    p = Profile.create(:first_name => nil, :last_name => nil, :gender => nil, :email => nil, :group => nil)
    assert_not_nil p.address_details
    assert !p.save
  end
  
  should 'get work information' do
    p = profiles(:user)
    assert p.work_details
    assert_nil profiles(:user3).work_details
  end
  
  should 'find next birthday' do
    p = profiles(:user)
    assert_not_nil p.birthdate_next
   
    p = profiles(:user3)
    assert_nil p.birthdate_next
  end
  
  should 'find next anniversary' do
    p = profiles(:user)
    assert_not_nil p.anniversary_next
   
    p = profiles(:user3)
    assert_nil p.anniversary_next
  end
 
  should 'find all happy days' do
    assert Profile.happy_day_range()
    assert Profile.find_all_happy_days()
  end
  should 'user female' do
    p = profiles(:user3)
    assert p.female?
  end
  should 'user male' do
    p = profiles(:user2)
    assert p.male?
  end
  should 'get premarital_lastname' do
    p = profiles(:user3)
    assert_equal(p.maiden_name,p.premarital_lastname)
  end
  should 'get premarital_lastname but no maiden name' do
    p = profiles(:user7)
    assert_equal(p.last_name,p.premarital_lastname)
  end
 
  should "find feed_item(item is not null) " do
    p = profiles(:user)
    assert !p.find_feed_items.blank?
  end
  
  should "find feed_item(item is  null) " do
    p = profiles(:user2)
    assert p.find_feed_items.blank?
  end
  
  should 'not find feed items' do
    p = profiles(:user3)
    assert p.find_feed_items.blank?
  end
  
end
