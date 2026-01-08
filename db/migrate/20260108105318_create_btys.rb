class CreateBtys < ActiveRecord::Migration[7.0]
  def change
    create_table :btys do |t|
      t.boolean :value, null: false
      t.date :date, null: false

      t.timestamps
    end
    
    add_index :btys, :date, unique: true
  end
end
