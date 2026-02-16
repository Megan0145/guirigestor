class CreateDingleExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :dingle_expenses do |t|
      t.string :payer, null: false
      t.string :description
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :expense_date, null: false

      t.timestamps
    end
  end
end
