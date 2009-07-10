class Title < ActiveRecord::Base
  
  validates_uniqueness_of :name, :case_sensitive => false
  before_save :name_titlecase
  
  def self.find_titles
    Title.find(:all, :order => 'name')
  end

  def name_titlecase
    self.name =self.name.titleize
  end
  
end
