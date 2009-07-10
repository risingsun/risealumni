require File.dirname(__FILE__) + '/../test_helper'

class WorkInformationTest < ActiveSupport::TestCase
  
  should_belong_to :profile
    
  should "prefix with http" do
    w = work_informations(:work)
    assert w.company_website.nil?
    assert w.company_website = 'maass.in'
    assert w.save
    assert_equal 'http://maass.in', w.reload.company_website
  end
  
  should "prefix with http if company website is blank" do
    w = work_informations(:work)
    assert w.company_website.nil?
    assert w.company_website = ''
    assert w.save
    assert_equal '',w.reload.company_website
  end
  
  should "prefix http is already given" do
    w = work_informations(:work)
    assert w.company_website.nil?
    assert w.company_website = 'http://maass.in'
    assert w.save
    assert_equal 'http://maass.in',w.reload.company_website
  end
end
