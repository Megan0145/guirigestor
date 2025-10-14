class AddServiceIdToOutgoingReceipts < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_receipts, :service_id, :integer
  end
end
