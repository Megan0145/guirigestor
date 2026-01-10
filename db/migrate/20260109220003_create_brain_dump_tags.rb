class CreateBrainDumpTags < ActiveRecord::Migration[7.0]
  def change
    create_table :brain_dump_tags do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :brain_dump_tags, :name, unique: true
  end
end
