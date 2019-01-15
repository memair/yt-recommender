namespace :youtube do
  desc "Get new videos from YouTube"
  task :get_videos => :environment do
    puts "started at #{DateTime.now}"
    channel = Channel.order('last_extracted_at ASC NULLS FIRST').first
    puts "updating #{channel.title}"
    channel.get_videos
    channel.update_attributes(last_extracted_at: DateTime.now)
    if channel.ordered
      puts "channel ordered by published_at"
      channel.set_video_order_from_published_at
    else
      puts "channel unordered or ordered by seasons"
      channel.set_video_order_from_seasons
    end
    puts "finished at #{DateTime.now}"
  end
end