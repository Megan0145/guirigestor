class CreateBrainDumps < ActiveRecord::Migration[7.0]
  def change
    create_table :brain_dumps do |t|
      t.text :content
      t.date :date

      t.timestamps
    end
  end
end
