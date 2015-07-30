require 'test_helper'

class QuickMessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quick_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quick_message" do
    assert_difference('QuickMessage.count') do
      post :create, :quick_message => { }
    end

    assert_redirected_to quick_message_path(assigns(:quick_message))
  end

  test "should show quick_message" do
    get :show, :id => quick_messages(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => quick_messages(:one).to_param
    assert_response :success
  end

  test "should update quick_message" do
    put :update, :id => quick_messages(:one).to_param, :quick_message => { }
    assert_redirected_to quick_message_path(assigns(:quick_message))
  end

  test "should destroy quick_message" do
    assert_difference('QuickMessage.count', -1) do
      delete :destroy, :id => quick_messages(:one).to_param
    end

    assert_redirected_to quick_messages_path
  end
end
