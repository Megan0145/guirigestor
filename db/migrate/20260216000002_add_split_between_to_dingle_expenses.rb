class AddSplitBetweenToDingleExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :dingle_expenses, :split_between, :string, default: "Megan,Thibault,Jordan"
  end
end
