# == Schema Information
#
# Table name: release_notes
#
#  id         :integer          not null, primary key
#  content    :string
#  author     :string
#  build_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ReleaseNoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
