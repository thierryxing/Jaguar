# == Schema Information
#
# Table name: projects
#
#  id             :integer          not null, primary key
#  title          :string
#  desc           :string
#  icon           :string
#  git_repo_url   :string
#  created_at     :datetime
#  updated_at     :datetime
#  clone_status   :integer
#  git_project_id :integer
#  type           :string           default("0")
#  platform       :integer          default("ios")
#  admin_id       :integer
#  user_id        :integer
#  identifier     :string
#  cron           :string
#  name           :string
#

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
