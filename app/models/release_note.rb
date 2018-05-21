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

class ReleaseNote < ApplicationRecord

  belongs_to :build

end
