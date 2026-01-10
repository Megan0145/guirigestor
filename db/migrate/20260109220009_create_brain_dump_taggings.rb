class CreateBrainDumpTaggings < ActiveRecord::Migration[7.0]
  def change
    create_table :brain_dump_taggings do |t|
      t.references :brain_dump, null: false, foreign_key: true
      t.references :brain_dump_tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
