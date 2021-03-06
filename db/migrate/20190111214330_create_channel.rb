class CreateChannel < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :yt_id, null: false
      t.string :title
      t.string :description
      t.boolean :ordered, default: false
      t.integer :max_age
      t.datetime :last_extracted_at

      t.timestamps
    end
  end
end
