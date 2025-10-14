class AddServiceAndAmountToOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_receipts, :service, :string
    add_column :outgoing_receipts, :amount, :decimal, precision: 10, scale: 2
  end
end
