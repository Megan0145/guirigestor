class CreateDigestMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :digest_messages do |t|
      t.references :digest, null: false, foreign_key: true
      t.string :role
      t.text :content

      t.timestamps
    end
  end
end
