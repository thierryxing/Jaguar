class CreateReleaseNote < ActiveRecord::Migration[5.1]
  def change
    create_table :release_notes do |t|
      t.text "content"
      t.integer "build_id"
      t.timestamps
    end
  end
end
