class CreateAutonomoPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :autonomo_payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: 'paid'
      t.datetime :uploaded_on
      t.text :notes

      t.timestamps
    end
  end
end
