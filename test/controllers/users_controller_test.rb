require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # HTTP response codes in MiniTests:
  # :success  -> 200
  # :redirect -> 300-399
  # :missing  -> 404
  # :error    -> 500-599

  test "should get authorise" do
    skip "Until authorize be fully implemented."
    get :authorise
    assert_response :success
  end

  test "should get correct user json representation" do
    skip "Method not done yet."
    put :update, {id: 1}  # GET /users/1
    assert_response(:success, "Incorrect response code.")
  end

end
