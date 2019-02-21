class AddIndexesForSpeed < ActiveRecord::Migration[5.2]
  def change
    add_index :videos, :yt_id
  end
end
