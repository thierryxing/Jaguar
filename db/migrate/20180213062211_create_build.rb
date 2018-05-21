class CreateBuild < ActiveRecord::Migration[5.1]
  def change
    create_table :builds do |t|
      t.string "version"
      t.integer "status"
      t.integer "project_id"
      t.string "build_number"
      t.string "job_id"
      t.string "release_notes"
      t.boolean "snapshot"
      t.integer "user_id"
      t.integer "env_template"
      t.integer "environment_id"
      t.timestamps
    end
  end
end
