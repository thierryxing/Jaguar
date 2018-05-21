class CreateUser < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string "name"
      t.string "username"
      t.string "gitlab_id"
      t.string "state"
      t.string "avatar_url"
      t.boolean "is_admin"
      t.string "private_token"
      t.timestamps
    end
  end
end
