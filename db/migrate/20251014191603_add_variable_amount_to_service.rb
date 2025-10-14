class AddVariableAmountToService < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :variable_amount, :boolean, default: false
  end
end
