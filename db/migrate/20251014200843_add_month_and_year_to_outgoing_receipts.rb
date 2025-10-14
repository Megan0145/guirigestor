class AddMonthAndYearToOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_receipts, :month, :integer
    add_column :outgoing_receipts, :year, :integer
  end
end
