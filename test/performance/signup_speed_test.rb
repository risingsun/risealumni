require File.dirname(__FILE__) + '/../test_helper'
require 'accounts_controller'
class AccountsController; def rescue_action(e) raise e end; end
class SignupSpeedTest < Test::Unit::TestCase
  #fixtures :profiles, :users
  def setup
    @controller = AccountsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  def test_100_user_signup
    @controller.logger.silence do
      elapsed_time = Benchmark.realtime do
        100.downto(1) do |i|
          post :signup, {
            :user => {
              :login => "lquire#{i}",
              :email => "lquire#{i}@example.com",
              :password => "lquire#{i}",
              :password_confirmation => "lquire#{i}",
              :terms_of_service => '1',
              :first_name => "Pooja#{i}", 
              :last_name => 'gupta', 
              :year => "2000"
            }
          }
          assert assigns(:u).save!
          assert_redirected_to home_path
        end
      end
      p elapsed_time
      assert elapsed_time < 24.00
    end 
  end


    
end

