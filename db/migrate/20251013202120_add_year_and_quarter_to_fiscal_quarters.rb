class AddYearAndQuarterToFiscalQuarters < ActiveRecord::Migration[7.0]
  def change
    add_column :fiscal_quarters, :year, :integer
    add_column :fiscal_quarters, :quarter, :string
  end
end
