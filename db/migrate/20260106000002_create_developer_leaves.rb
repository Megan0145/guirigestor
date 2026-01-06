class CreateDeveloperLeaves < ActiveRecord::Migration[7.0]
  def change
    create_table :developer_leaves do |t|
      t.references :tonic_developer, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :notes
      t.timestamps
    end
    
    add_index :developer_leaves, [:start_date, :end_date]
  end
end

