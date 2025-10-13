class ChangeMonthlyRateToRateOnInvoices < ActiveRecord::Migration[7.0]
  def change
    rename_column :invoices, :monthly_rate, :rate
  end
end
