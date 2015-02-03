require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "number of test users equals 1000" do
     assert User.count == 1000
  end
end
