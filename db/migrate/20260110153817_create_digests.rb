class CreateDigests < ActiveRecord::Migration[7.0]
  def change
    create_table :digests do |t|
      t.string :digest_type
      t.string :schedule_period
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
