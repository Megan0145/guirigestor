class CreateFiscalQuarters < ActiveRecord::Migration[7.0]
  def change
    create_table :fiscal_quarters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :status, default: 'active'
      t.text :notes
      t.string :identifier
      t.string :passcode

      t.timestamps
    end
  end
end
