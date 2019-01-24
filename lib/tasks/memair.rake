require "#{Rails.root}/app/helpers/memair_helper"
include MemairHelper

namespace :memair do
  desc "Make new recommendations"
  task :make_recommendations => :environment do
    puts "started at #{DateTime.now}"
    user = User.where('last_recommended_at IS NULL OR last_recommended_at < ?', 12.hours.ago).order('last_recommended_at ASC NULLS FIRST').first
    if user
      puts "recommending for #{user.email}"

      previous = previous_watched_and_recommended(user.memair_access_token)

      previous_recommended_video_ids = Video.where(yt_id: previous[:recommended]).ids
      previous_watched_video_ids = Video.where(yt_id: previous[:watched]).ids
      recently_watched_video_ids = previous_watched_video_ids[0..25]

      sql = """
        WITH
          time_sensitive AS (
            SELECT v.id, 75 AS priority, '#{DateTime.now + 36.hours}'::text AS expires_at
            FROM
              videos v
              JOIN channels c ON v.channel_id = c.id
            WHERE
              v.id NOT IN (#{previous_recommended_video_ids.empty? ? 'NULL' : previous_recommended_video_ids.join(",")})
              AND v.published_at > CURRENT_DATE - (INTERVAL '1 DAY' * c.max_age)
            ORDER BY published_at DESC
            LIMIT 5
            ),
          series AS (
            SELECT v.id, 85 AS priority, '#{DateTime.now + 72.hours}'::text AS expires_at
            FROM
              videos v
              JOIN videos pv ON v.previous_video_id = pv.id
            WHERE
              v.id NOT IN (#{previous_recommended_video_ids.empty? ? 'NULL' : previous_recommended_video_ids.join(",")})
              AND pv.id IN (#{recently_watched_video_ids.empty? ? 'NULL' : recently_watched_video_ids.join(",")})
            ORDER BY RANDOM()
            LIMIT 5
          ),
          others AS (
            SELECT v.id, 50 AS priority, '#{DateTime.now + 48.hours}'::text AS expires_at
            FROM
            videos v
            JOIN channels c ON v.channel_id = c.id
            WHERE
              v.id NOT IN (#{previous_recommended_video_ids.empty? ? 'NULL' : previous_recommended_video_ids.join(",")})
              AND v.previous_video_id IS NULL
              AND NOT c.ordered
            ORDER BY RANDOM()
            LIMIT 10
          )
        SELECT *
        FROM time_sensitive
        UNION
        SELECT *
        FROM series
        UNION
        SELECT *
        FROM others
      """
      results = ActiveRecord::Base.connection.execute(sql).to_a

      recommendations = []
      puts "#{results.count} videos collected"
      results.each do |video|
        recommendations << Recommendation.new(video: Video.find(video['id']), priority: video['priority'], expires_at: video['expires_at'])
      end
      mutation = generate_recommendation_mutation(recommendations)
      response = Memair.new(user.memair_access_token).query(mutation)
      puts "Bulk Create: #{response['data']['BulkCreate']['id']}"
      user.update(last_recommended_at: DateTime.now)
    else
      puts "no users requiring recommending"
    end
    puts "finished at #{DateTime.now}"
  end
end