class UpdateForigenKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :preferences, :users
    add_foreign_key :preferences, :users, on_delete: :cascade
  end
end
