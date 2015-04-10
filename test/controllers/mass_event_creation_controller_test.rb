require 'test_helper'

class MassEventCreationControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get help" do
    get :help
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
