class Video < ApplicationRecord
  belongs_to :channel
  belongs_to :previous_video, class_name: 'Video', foreign_key: 'previous_video_id', optional: true
  validates :yt_id, uniqueness: true
end
