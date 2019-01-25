class AddingMultiColumnIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :preferences, [:user_id, :channel_id], unique: true
  end
end
