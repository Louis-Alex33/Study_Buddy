require "test_helper"

class MultiplayerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get multiplayer_index_url
    assert_response :success
  end
end
