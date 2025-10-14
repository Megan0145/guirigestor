class CreateServices < ActiveRecord::Migration[7.0]
  def change
    create_table :services do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.decimal :amount, precision: 10, scale: 2
      t.string :currency, default: 'EUR'
      t.string :status, default: 'active'
      t.timestamps
    end
  end
end
