class AddDeletedChannel < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :deleted_at, :datetime
  end
end
