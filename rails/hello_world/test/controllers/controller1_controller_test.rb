require "test_helper"

class Controller1ControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get controller1_index_url
    assert_response :success
  end
end
