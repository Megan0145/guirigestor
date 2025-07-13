class RenameDescriptionToNotesInInvoices < ActiveRecord::Migration[7.0]
  def change
    remove_column :invoices, :description, :text
  end
end
