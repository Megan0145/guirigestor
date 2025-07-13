class CreateInvoiceLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :invoice_line_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string :description
      t.decimal :rate
      t.integer :quantity
      t.decimal :total

      t.timestamps
    end
  end
end
