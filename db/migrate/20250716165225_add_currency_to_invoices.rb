class AddCurrencyToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :currency, :string, null: false, default: 'EUR'
  end
end
