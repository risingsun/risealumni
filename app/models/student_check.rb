# == Schema Information
# Schema version: 2
#
# Table name: student_checks
#
#  id          :integer(11)   not null, primary key
#  name        :string(255)   
#  first_name  :string(255)   
#  middle_name :string(255)   
#  last_name   :string(255)   
#  birth_date  :date          
#  sex         :string(255)   
#  f_name      :string(255)   
#  m_name      :string(255)   
#  f_desg      :string(255)   
#  m_desg      :string(255)   
#  r_add1      :string(255)   
#  r_add2      :string(255)   
#  r_add3      :string(255)   
#  o_add1      :string(255)   
#  o_add2      :string(255)   
#  o_add3      :string(255)   
#  o_ph_no     :string(255)   
#  r_ph_no     :string(255)   
#  mobile      :string(255)   
#  enroll_no   :string(255)   
#  year        :string(255)   
#  roll_no     :string(255)   
#  classname   :string(255)   
#  house_name  :string(255)   
#  profile_id  :integer(11)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  e_mail_1    :string(255)   
#  e_mail_2    :string(255)   
#

class StudentCheck < ActiveRecord::Base
  
  belongs_to :profile
  
  alias_attribute :house, :house_name
  alias_attribute :examrollno,  :roll_no
  alias_attribute :rollno, :roll_no
  alias_attribute :enrollno,  :enroll_no
  alias_attribute :occu, :f_desg
  alias_attribute :date_of_birth, :birth_date
  alias_attribute :email_1, :e_mail_1
  alias_attribute :email_2, :e_mail_2

  validates_presence_of :name
  validates_presence_of :year
  #validates_presence_of :roll_no
  #validates_uniqueness_of :roll_no, :scope => [:year]

  before_save :titlecase_fields, :fix_birthdays, :split_name
  before_validation :fix_name

  named_scope :year, lambda{|y| {:conditions => {:year => y}}}
  named_scope :unregistered, :conditions => ["profile_id is null"]
  named_scope :name_order, :order => 'first_name, last_name'
  named_scope :ordered, lambda { |*order|
              { :order => order.flatten.first}}
  named_scope :with_profile, :include => :profile
  # Titlecase the bunch of these fields
  def titlecase_fields
    %w[ name f_name m_name f_desg m_desg house_name first_name middle_name last_name].each do |attribute|
      if (attribute_present?(attribute) and !self[attribute].blank?)
        self[attribute] = self[attribute].strip.titlecase
      end
    end
    true
  end

  def split_name
    if first_name.blank? 
      names = self.name.split(" ") 
      self.first_name = names.shift 
      self.last_name = names.pop 
      self.middle_name = names.join(" ") 
    end 
    true
  end 

  def fix_name
    if self.name.blank?
      self.name = self.full_name
    end
  end
  
  def fix_birthdays
    if self.birth_date && self.birth_date.year < 100
      self.birth_date = Date.new(self.birth_date.year+1900, self.birth_date.month, self.birth_date.day)
    end
    true
  end
  
  def self.match_details?(profile,update=true)
    return true if DISABLE_STUDENT_CHECKING # adding to disable student table checking
    student = StudentCheck.find(:first, 
                                :conditions => 
                                  ["first_name like ? and last_name like ? and student_checks.year = ? and (profile_id is null or profile_id = ?)" ,  
                                  profile.first_name, 
                                  profile.premarital_lastname, 
                                  profile.group,
                                  profile])
    if student
      if update
        student.update_attribute('profile',profile) 
      end
      return true
    end
    return false
  end
  
  def self.unregistered_batch_members(year)
    # Find all Students by given year
    year(year).unregistered.name_order.all
  end

  def self.unregistered_batch_count
    details = unregistered.all(:group => 'student_checks.year', :order => 'student_checks.year', :select => 'student_checks.year, count(*) as count')
    details_hash = {}
    details.each {|p| details_hash[p.year] = p.count.to_i}
    details_hash
  end
  
  def full_name
    [first_name,middle_name,last_name].reject(&:blank?).compact.join(" ").titlecase
  end
  
  def emails
    @emails ||= [email_1,email_2].reject(&:blank?).map(&:strip).uniq
  end

  def self.with_emails
    self.all(:conditions => "e_mail_1 != '' or e_mail_2 != ''")
  end

  def self.get_students(options)
    scope = StudentCheck.scoped({})
    scope = scope.ordered("student_checks.year,student_checks.first_name,student_checks.last_name")
    scope = scope.with_profile
    scope = scope.year(options[:year]) unless options[:year].blank?
    scope = scope.all(options[:all]) unless options[:all].blank?
    scope
  end

  def self.alpha_index
    all(:select => 'name').map{|n| [n.name]}.flatten.compact.map{|x|x.strip.first.upcase}.uniq.sort
  end

end
