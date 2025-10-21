class AddAssignedToOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_receipts, :assigned, :boolean, default: false, null: false
  end
end
