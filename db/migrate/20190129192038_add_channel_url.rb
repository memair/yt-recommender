class AddChannelUrl < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :thumbnail_url, :string
  end
end
