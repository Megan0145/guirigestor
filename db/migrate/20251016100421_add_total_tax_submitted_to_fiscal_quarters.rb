class AddTotalTaxSubmittedToFiscalQuarters < ActiveRecord::Migration[7.0]
  def change
    add_column :fiscal_quarters, :total_tax_submitted, :decimal, precision: 10, scale: 2, default: 0.0
  
  end
end
