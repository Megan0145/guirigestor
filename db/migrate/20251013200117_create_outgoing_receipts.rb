class CreateOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :outgoing_receipts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'paid'
      t.datetime :uploaded_on
      t.text :notes

      t.timestamps
    end
  end
end
