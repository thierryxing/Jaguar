class CreateProject < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string "title"
      t.string "desc"
      t.string "icon"
      t.string "git_repo_url"
      t.integer "git_project_id"
      t.string "type", default: "0"
      t.integer "platform", default: 0
      t.integer "admin_id"
      t.integer "user_id"
      t.string "identifier"
      t.string "name"
      t.timestamps
    end
  end
end
