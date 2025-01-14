require "test_helper"

class ImageControllerTest < ActionDispatch::IntegrationTest
  Minitest.after_run { puts "ImageControllerTest completed" }

  test "get index without 'url' parameter" do
    get image_index_url
    assert_response :bad_request
  end

  test "get index with invalid 'url' parameter" do
    get image_index_url, params: { url: "invalid" }
    assert_response :bad_request
  end

  test "get index with valid 'url' parameter" do
    get image_index_url, params: { url: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png" }
    assert_response :success
  end
end
