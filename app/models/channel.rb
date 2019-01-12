class Channel < ApplicationRecord
  before_save :set_details
  has_many :videos, dependent: :delete_all

  def get_videos
    yt_channel.videos.each do |yt_video|
      self.videos.where(yt_id: yt_video.id).first_or_create do |video|
        video.yt_id        = yt_video.id
        video.title        = yt_video.title
        video.description  = yt_video.description
        video.tags         = yt_video.tags
        video.published_at = yt_video.published_at
        video.duration     = yt_video.duration
      end
    end
  end

  private
    def set_details
      self.title       = yt_channel.title
      self.description = yt_channel.description
    end

    def yt_channel
      Yt::Channel.new id: self.yt_id
    end
end
