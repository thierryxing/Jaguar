class AddColumnTagToEnvironment < ActiveRecord::Migration[5.1]
  def change
    add_column :environments, :git_tag, :string
  end
end
