class CreateTonicDevelopers < ActiveRecord::Migration[7.0]
  def change
    create_table :tonic_developers do |t|
      t.string :name, null: false
      t.string :project
      t.timestamps
    end
  end
end

