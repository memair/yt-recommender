class AddLastRecommendedAt < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_recommended_at, :datetime
  end
end
