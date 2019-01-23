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

  desc "Usage: rake youtube:add_channel[url,ordered,max_age]"
  task :add_channel, [:url, :ordered, :max_age] => [:environment] do |task, args|
    puts "getting channel id for #{args[:url]}"
    ordered = ActiveModel::Type::Boolean.new.cast(args[:ordered]) || false
    response = HTTParty.get(args[:url], timeout: 180)
    channel_id = /yt.setConfig\('CHANNEL_ID', "(([a-z]|[A-Z]|\d|-|_){24})"\);/.match(response.body)[1]
    puts "Creating channel for channel_id: #{channel_id}"
    channel = Channel.create(yt_id: channel_id, ordered: ordered, max_age: args[:max_age])
    if channel.valid?
      puts "#{channel.title} created"
    else
      puts "error: #{channel.errors.details.to_s}"
    end
  end
end