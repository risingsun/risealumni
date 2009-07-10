class WorkInformation < ActiveRecord::Base
  belongs_to :profile
  
  def company_website= val
    write_attribute(:company_website, fix_http(val))
  end
  
  protected
  def fix_http str
    return '' if str.blank?
    str.starts_with?('http') ? str : "http://#{str}"
  end
  
end
