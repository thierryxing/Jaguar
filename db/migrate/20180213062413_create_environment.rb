class CreateEnvironment < ActiveRecord::Migration[5.1]
  def change
    create_table :environments do |t|
      t.string "git_branch"
      t.string "scheme"
      t.integer "project_id"
      t.boolean "is_default"
      t.string "main_module"
      t.string "gradle_task"
      t.string "name"
      t.integer "clone_status", default: 0
      t.string "ding_access_token"
      t.string "cron"
      t.integer "fastlane_template_id"
      t.timestamps
    end
  end
end
