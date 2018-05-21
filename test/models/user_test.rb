# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string
#  username      :string
#  gitlab_id     :string
#  state         :string
#  avatar_url    :string
#  is_admin      :boolean
#  private_token :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
