class AddHalfDayToDeveloperLeaves < ActiveRecord::Migration[7.0]
  def change
    add_column :developer_leaves, :start_half_day, :boolean, default: false, null: false
    add_column :developer_leaves, :end_half_day, :boolean, default: false, null: false
  end
end
