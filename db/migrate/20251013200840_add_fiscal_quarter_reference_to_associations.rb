class AddFiscalQuarterReferenceToAssociations < ActiveRecord::Migration[7.0]
  def change
    add_reference :autonomo_payments, :fiscal_quarter, foreign_key: true
    add_reference :outgoing_receipts, :fiscal_quarter, foreign_key: true
    add_reference :invoices, :fiscal_quarter, foreign_key: true
  end
end
