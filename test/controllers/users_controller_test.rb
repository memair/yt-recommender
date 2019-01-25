require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @user = users(:admin)
    @another_user = users(:user)
  end

  test "non signed in user is redirected to signin" do
    get :profile
    assert_redirected_to new_user_session_path 
  end

  test "signed in user gets preferences" do
    sign_in(@user)
    get :profile
    assert_response :success
  end

  test "user can update their preferences" do
    sign_in(@user)
    another_users_preference = @another_user.preferences.first
    initial_frequency = another_users_preference.frequency
    post :update, params: { preferences: {another_users_preference.id => 10} }
    assert_redirected_to user_path
    assert_equal initial_frequency, another_users_preference.frequency
  end

  test "user updates preferences" do
    sign_in(@user)
    users_preference = @user.preferences.first
    updated_frequency = ([*0..10] - [users_preference.frequency]).sample
    post :update, params: { preferences: {users_preference.id => updated_frequency} }
    assert_equal updated_frequency, @user.preferences.first.frequency
  end
end