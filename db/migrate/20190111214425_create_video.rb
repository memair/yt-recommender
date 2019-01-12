class CreateVideo < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :yt_id, null: false
      t.datetime :published_at
      t.string :title
      t.string :description
      t.integer :duration
      t.jsonb :tags
      t.references :channel, foreign_key: true
      t.references :previous_video, class: 'Video'

      t.timestamps
    end
  end
end
