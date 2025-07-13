class UpdateInvoicesWithAdditionalFields < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :invoice_number, :string
    add_column :invoices, :tax_rate, :decimal, precision: 5, scale: 2
    add_column :invoices, :terms, :text
    add_column :invoices, :bank_details, :text
    add_column :invoices, :notes, :text
  end
end
