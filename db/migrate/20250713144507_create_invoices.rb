class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :frequency
      t.decimal :monthly_rate
      t.string :recipient_company_name
      t.string :recipient_vat_number
      t.text :recipient_address
      t.string :recipient_email
      t.string :sender_company_name
      t.string :sender_tax_number
      t.text :sender_address
      t.text :description
      t.date :issued_on
      t.date :due_on
      t.decimal :total_amount

      t.timestamps
    end
  end
end
