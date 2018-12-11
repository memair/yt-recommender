class AddingUserFields < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :memair_access_token, :string
  end
end
