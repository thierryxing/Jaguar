class CreateFastlaneTemplate < ActiveRecord::Migration[5.1]
  def change
    create_table :fastlane_templates do |t|
      t.string "name"
      t.string "command"
      t.string "platform"
      t.timestamps
    end
  end
end
