class CreateDigestBrainDumps < ActiveRecord::Migration[7.0]
  def change
    create_table :digest_brain_dumps do |t|
      t.references :digest, null: false, foreign_key: true
      t.references :brain_dump, null: false, foreign_key: true

      t.timestamps
    end
  end
end
