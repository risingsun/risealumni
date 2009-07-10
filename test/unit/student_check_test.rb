require File.dirname(__FILE__) + '/../test_helper'

class StudentCheckTest < ActiveSupport::TestCase
  
  should_require_attributes :name, :year
  should_belong_to :profile
  
  def test_for_alias_attribute_house_name
    sc = student_checks(:student1)
    assert_equal sc.house_name, sc.house, "Alias attribute value can't be Different"
  end
  
  def test_for_alias_attribute_exroll_no
    sc = student_checks(:student1)
    assert_equal sc.roll_no, sc.examrollno, "Alias attribute value can't be Different"
  end
  
  def test_for_alias_attribute_roll_no
    sc = student_checks(:student1)
    assert_equal sc.roll_no, sc.rollno, "Alias attribute value can't be Different"
  end
  
  def test_for_alias_attribute_enroll_no
    sc = student_checks(:student1)
    assert_equal sc.enroll_no, sc.enrollno, "Alias attribute value can't be Different"
  end
  
  def test_for_alias_attribute_f_desg
    sc = student_checks(:student1)
    assert_equal sc.f_desg, sc.occu, "Alias attribute value can't be Different"
  end
  
  def test_before_save_title_case
    sc = StudentCheck.create(:name => 'david h hanson', :f_name => 'jason moor', :m_name => 'lucy moor', :f_desg => 'engineer', :m_desg => 'lecturer', :house_name => 'moon', :year => 2006 )
    assert_equal 'David H Hanson', sc.name
    assert_equal 'Jason Moor', sc.f_name
    assert_equal 'Lucy Moor', sc.m_name
    assert_equal 'Engineer', sc.f_desg
    assert_equal 'Lecturer', sc.m_desg
    assert_equal 'Moon', sc.house_name    
    assert sc.valid?
  end
  
  def test_before_save_title_case_if_values_are_already_in_title_case
    sc = StudentCheck.create(:name => 'David H Hanson', :year => 2006 )
    assert_equal 'David H Hanson', sc.name
    assert sc.valid?
  end
  
  def test_before_save_title_case_if_values_using_special_characters
    sc = StudentCheck.create(:name => "D'd h Hanson", :year => 2006 )
    assert sc.valid?
  end
  
  def test_before_save_title_case_if_using_nil_value
    sc = StudentCheck.create(:name => '', :year => 2006 )
    assert !sc.valid?
    assert sc.errors.on(:name)
  end
  
  def test_before_save_title_case_if_using_integer_string
    sc = StudentCheck.create(:name => '1111111111', :year => 2006 )
    assert sc.valid?
  end

  def test_before_filter_split_name
    sc = StudentCheck.create(:name => 'david h hanson', :year => 2006)
    assert_equal 'David H Hanson', sc.name
    assert_equal 'David', sc.first_name
    assert_equal 'H', sc.middle_name
    assert_equal 'Hanson', sc.last_name
    assert sc.valid?
  end
  
  def test_before_filter_split_name_if_donot_taking_fullname
    sc = StudentCheck.create(:name => 'david hanson', :year => 2006)
    assert_equal 'David Hanson', sc.name
    assert_equal 'David', sc.first_name
    assert_equal 'Hanson', sc.last_name
    assert sc.valid?
  end
  
  def test_before_filter_split_name_if_taking_nil_value
    sc = StudentCheck.create(:name => '', :year => 2006)
    assert !sc.valid?
  end
  

  def test_before_filter_split_name_if_invalid_name
    sc = StudentCheck.create(:name => "a'saxena", :year => 2006)
    assert "a'saxena", sc.name
    assert sc.valid?
  end
  
  def test_match_details
    pr = profiles(:user)
    assert StudentCheck.match_details?(pr)
  end
  def test_match_details_with_female_maiden_name
    pr = profiles(:user3)
    assert StudentCheck.match_details?(pr)
  end
  def test_match_details_without_female_maiden_name
    pr = profiles(:user7)
    assert StudentCheck.match_details?(pr)
  end
  def test_match_details_user_do_not_match
    pr = profiles(:user2)
    assert StudentCheck.match_details?(pr, false)
  end
  
  def test_unregistered_batch_members
    sc = StudentCheck.unregistered_batch_members(2006)
    assert sc
  end
  
  def test_unregistered_batch_members_if_passing_wrong_argument
    sc = StudentCheck.unregistered_batch_members(123)
    assert_equal [], sc 
  end
end

