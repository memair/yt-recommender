require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "admins if memair.com address" do
    user = User.create(email: 'greg@memair.com', password: 'password')
    assert user.admin?
  end

  test "user if non memair.com address" do
    user = User.create(email: 'cats@gmeow.com', password: 'password')
    refute user.admin?
  end
end
