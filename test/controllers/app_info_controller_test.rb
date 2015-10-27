require 'test_helper'

class AppInfoControllerTest < ActionController::TestCase
  test "should get deployinfo" do
    get :deployinfo
    assert_response :success
  end

end
