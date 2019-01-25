class AddingDefaultFrequency < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :default_frequency, :integer, default: 4
  end
end
