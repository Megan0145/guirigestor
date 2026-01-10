class AddRawContentToBrainDumps < ActiveRecord::Migration[7.0]
  def change
    add_column :brain_dumps, :raw_content, :text
  end
end
