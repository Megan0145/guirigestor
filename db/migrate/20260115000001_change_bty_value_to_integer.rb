class ChangeBtyValueToInteger < ActiveRecord::Migration[7.0]
  def up
    # Add a new integer column
    add_column :btys, :value_int, :integer
    
    # Migrate existing data: true -> 1, false -> -1
    # Use proper boolean comparison for PostgreSQL compatibility
    execute <<-SQL
      UPDATE btys SET value_int = CASE WHEN value = true THEN 1 ELSE -1 END
    SQL
    
    # Remove old column and rename new one
    remove_column :btys, :value
    rename_column :btys, :value_int, :value
    
    # Add not null constraint
    change_column_null :btys, :value, false
  end
  
  def down
    # Add boolean column back
    add_column :btys, :value_bool, :boolean
    
    # Migrate data back: 1 -> true, -1/0 -> false
    # Use proper boolean values for PostgreSQL compatibility
    execute <<-SQL
      UPDATE btys SET value_bool = CASE WHEN value = 1 THEN true ELSE false END
    SQL
    
    # Remove integer column and rename boolean
    remove_column :btys, :value
    rename_column :btys, :value_bool, :value
    
    change_column_null :btys, :value, false
  end
end
