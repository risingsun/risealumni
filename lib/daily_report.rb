class DailyReport
  def self.daily_signup_report
    profiles = Profile.recent(Date.today - 1.days)
    AccountMailer.deliver_daily_signup_report(profiles) unless profiles.blank?
  end
end