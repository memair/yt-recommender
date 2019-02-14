class Channel < ApplicationRecord
  include ChannelHelper

  before_save :set_details
  has_many :videos, dependent: :delete_all
  has_many :preferences, dependent: :delete_all
  after_create :create_preferences

  validates :yt_id, uniqueness: true
  validates_numericality_of :max_age, greater_than_or_equal_to: 0, allow_nil: true, message: 'must be between 0 & 100'
  validates_numericality_of :default_frequency, greater_than_or_equal_to: 0, less_than_or_equal_to: 10, message: 'must be between 0 & 10'

  def get_videos
    yt_channel.videos.each do |yt_video|
      begin
        if yt_video.duration.to_i > 0
          self.videos.where(yt_id: yt_video.id).first_or_create do |video|
            video.yt_id        = yt_video.id
            video.title        = yt_video.title
            video.description  = yt_video.description
            video.tags         = yt_video.tags
            video.published_at = yt_video.published_at
            video.duration     = yt_video.duration
          end
        else
        end
      rescue Yt::Errors::NoItems
        # ignore live videos that fail
      end
    end
  end

  def set_video_order_from_seasons
    get_playlists.each do |playlist|
      if playlist_is_a_season?(playlist)
        items = []
        previous_video_id = nil
        playlist.playlist_items.each do |item|
          video = Video.find_by(yt_id: item.video_id)
          unless video.nil?
            video.update_attributes(previous_video_id: previous_video_id)
            previous_video_id = video.id
          end
        end
      end
    end
  end

  def set_video_order_from_published_at
    videos = self.videos.order(published_at: :asc)
    previous_video = nil
    videos.each do |video|
      video.update_attributes(previous_video: previous_video) if video.previous_video.nil?
      previous_video = video
    end
  end

  def create_preferences
    User.all.each do |user|
      Preference.create(
        user: user,
        channel: self,
        frequency: self.default_frequency
      )
    end
  end

  def update_details
    self.update_attributes(
      title: yt_channel.title,
      description: yt_channel.description,
      thumbnail_url: yt_channel.thumbnail_url
    )
  end

  private

    def yt_channel
      @yt_channel = @yt_channel || (Yt::Channel.new id: self.yt_id)
    end
    
    def set_details
      self.title         = yt_channel.title
      self.description   = yt_channel.description
      self.thumbnail_url = yt_channel.thumbnail_url
    end

    def get_playlists
      playlists = []
      yt_channel.playlists.each do |playlist|
        playlists += [playlist]
      end
      playlists
    end
end
