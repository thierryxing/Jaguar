class CreateService < ActiveRecord::Migration[5.1]
  def change
    create_table :services do |t|
      t.string "type"
      t.string "title"
      t.integer "environment_id"
      t.boolean "active", default: false, null: false
      t.text "properties"
      t.boolean "template", default: false
      t.integer "service_type"
      t.timestamps
    end
  end
end
