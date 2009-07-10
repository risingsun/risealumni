require File.dirname(__FILE__) + '/../test_helper'

class JavascriptsControllerTest < ActionController::TestCase
 
  def test_get_hide_announcement
    get :hide_announcement ,:format =>'js'
  end
end
