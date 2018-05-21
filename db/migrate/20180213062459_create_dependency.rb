class CreateDependency < ActiveRecord::Migration[5.1]
  def change
    create_table :dependencies do |t|
      t.string "name"
      t.string "version"
      t.integer "project_id"
      t.boolean "is_internal", default: false
      t.timestamps
    end
  end
end
