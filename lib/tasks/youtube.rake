namespace :youtube do
  desc "Get new videos from YouTube. Usage: rake youtube:get_videos 3"
  task :get_videos => :environment do
    puts "started at #{DateTime.now}"

    ARGV.each { |a| task a.to_sym do ; end }
    i = (ARGV[1] || 1).to_i

    puts "getting videos from #{i} #{'channel'.pluralize(i)}"

    def never_extracted
      Channel.where(last_extracted_at: nil).where(deleted_at: nil).first
    end

    def not_extracted_last_7_days
      Channel.
        where("last_extracted_at < ?", DateTime.now - 7.days).
        where(deleted_at: nil).
        order(last_extracted_at: :asc).
        first
    end

    def rarely_posting_channel
      Channel.
        joins(:videos).
        where("published_at > ?", DateTime.now - 14.days).
        where("last_extracted_at < ?", DateTime.now - 6.hours).
        where(deleted_at: nil).
        order(last_extracted_at: :asc).
        first
    end

    def frequently_posting_time_sensitive_channel
      Channel.
        joins(:videos).
        where("published_at > ?", DateTime.now - 7.days).
        where("last_extracted_at < ?", DateTime.now - 30.minutes).
        where(deleted_at: nil).
        where.not(max_age: nil).
        group(:id).
        having("COUNT(channel_id) > 2").
        order(last_extracted_at: :asc).
        first
    end

    def catch_all
      Channel.where(deleted_at: nil).order(last_extracted_at: :asc).first
    end

    i.times do
      channel = never_extracted || not_extracted_last_7_days || rarely_posting_channel || frequently_posting_time_sensitive_channel || catch_all

      begin
        puts "updating details for #{channel.title}"
        channel.update_details
        puts "getting videos for #{channel.title}"
        channel.get_videos
      rescue Yt::Errors::NoItems
        puts "No Items, channel probably deleted"
        channel.update(deleted_at: DateTime.now)
        Preferences.where(channel_id: channel.id).delete_all
        Video.where(channel_id: channel.id).delete_all
      end

      channel.update(last_extracted_at: DateTime.now)

      if channel.ordered
        puts "channel ordered by published_at"
        channel.set_video_order_from_published_at
      else
        puts "channel unordered or ordered by seasons"
        channel.set_video_order_from_seasons
      end
    end

    puts "finished at #{DateTime.now}"
  end

  desc "Usage: rake youtube:add_channel[url,ordered,max_age]"
  task :add_channel, [:url, :ordered, :max_age] => [:environment] do |task, args|
    puts "getting channel id for #{args[:url]}"
    ordered = ActiveModel::Type::Boolean.new.cast(args[:ordered]) || false
    response = HTTParty.get(args[:url], timeout: 180)
    channel_id = /<meta itemprop="channelId" content="(([a-z]|[A-Z]|\d|-|_){24})">/.match(response.body)[1]

    puts "Creating channel for channel_id: #{channel_id}"
    channel = Channel.create(yt_id: channel_id, ordered: ordered, max_age: args[:max_age])
    if channel.valid?
      puts "#{channel.title} created"
    else
      puts "error: #{channel.errors.details.to_s}"
    end
  end
end