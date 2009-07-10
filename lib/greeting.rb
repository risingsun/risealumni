class Greeting

  attr_accessor :twitter

  def initialize
    if TWITTER_ENABLED
      @twitter = Twitter::Client.from_config('twitter.yml' , 'user' )
    end
  end

  def day_greetings
    bday_greeting
    anniversary_greeting
  end

  def bday_greeting
    Profile.today_birthday.each do |p|
      AccountMailer.deliver_bday_greeting(p)
      @twitter.status(:post, "#{SITE_NAME} wishes #{p.full_name} a very Happy Birthday.") if @twitter
    end
  end

  def anniversary_greeting
    Profile.today_anniversary.each do |p|
      AccountMailer.deliver_anniversary_greeting(p)
      @twitter.status(:post, "#{SITE_NAME} wishes #{p.full_name} a very happy Anniversary.") if @twitter
    end
  end

end
