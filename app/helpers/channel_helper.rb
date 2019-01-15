module ChannelHelper
  def playlist_is_a_season?(playlist)
    !!playlist.title.match(/: Season \d*$/)
  end
end
