class AddCurrencyToOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_receipts, :currency, :string, default: 'EUR'
  end
end
