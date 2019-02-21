class User < ApplicationRecord
  has_many :preferences
  before_destroy :revoke_token
  after_create :create_preferences

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:memair]

  ADMINS = %w( greg@gho.st )

  def admin?
    ADMINS.include? self.email
  end

  def self.from_memair_omniauth(omniauth_info)
    data        = omniauth_info.info
    credentials = omniauth_info.credentials

    user = User.where(email: data['email']).first

    unless user
     user = User.create(
       email:    data['email'],
       password: Devise.friendly_token[0,20]
     )
    end

    user.memair_access_token = credentials['token']
    user.save
    user
  end

  def create_preferences
    Channel.all.each do |channel|
      Preference.create(
        user: self,
        channel: channel,
        frequency: channel.default_frequency
      )
    end
  end

  def get_recommendations(priority=75)
    previous = previous_watched_and_recommended(self.memair_access_token)

    previous_recommended_video_ids = Video.where(yt_id: previous[:recommended]).ids
    previous_watched_video_ids = Video.where(yt_id: previous[:watched]).ids
    recently_watched_video_ids = previous_watched_video_ids[0..100]

    sql = """
      WITH
        timeless AS (
          SELECT v.id, v.channel_id, (NOW() + INTERVAL '5' DAY)::text AS expires_at, v.published_at, v.duration, 3 AS type_weight
          FROM
            channels c
            JOIN videos v ON c.id = v.channel_id
          WHERE
            max_age IS NULL
            AND previous_video_id IS NULL
            #{'AND v.id NOT IN (' + previous_recommended_video_ids.join(",") + ')' unless previous_recommended_video_ids.empty?}
        ),
        timely AS (
          SELECT v.id, v.channel_id, (NOW() + INTERVAL '3' DAY)::text AS expires_at, v.published_at, v.duration, 7 AS type_weight
          FROM
            channels c
            JOIN videos v ON c.id = v.channel_id
          WHERE
            (v.published_at > (NOW() - INTERVAL '1' DAY * c.max_age))
            AND previous_video_id IS NULL
            #{'AND v.id NOT IN (' + previous_recommended_video_ids.join(",") + ')' unless previous_recommended_video_ids.empty?}
        ),
        series AS (
          SELECT v.id, v.channel_id, (NOW() + INTERVAL '7' DAY)::text AS expires_at, v.published_at, v.duration, 6 AS type_weight
          FROM
            videos v
            JOIN videos pv ON v.previous_video_id = pv.id
          WHERE
          #{
            if recently_watched_video_ids.empty? || previous_recommended_video_ids.empty?
              "FALSE"
            else
              """
                pv.id NOT IN (#{recently_watched_video_ids.join(",")})
                AND v.id IN (#{previous_recommended_video_ids.join(",")})
              """
            end
        }
        ),
        recommendable AS (
          SELECT
            v.id,
            v.expires_at,
            v.duration,
            v.published_at,
            c.thumbnail_url,
            p.frequency * v.type_weight * (EXTRACT(EPOCH FROM v.published_at) - 1000000000) * (2 + RANDOM()) AS weight,
            COUNT(v.channel_id) OVER (PARTITION BY v.channel_id) AS channel_count
          FROM (
            SELECT *
            FROM timeless
            UNION
            SELECT *
            FROM timely
            UNION
            SELECT *
            FROM series) v
            JOIN preferences p ON v.channel_id = p.channel_id AND p.user_id = #{self.id}
            JOIN channels c ON v.channel_id = c.id
          ORDER BY 4 DESC
        ),
        ordered AS (
          SELECT *, SUM(duration) OVER (ORDER BY weight DESC) AS cumulative_duration
          FROM recommendable
          WHERE channel_count < 3
        )
      SELECT id, expires_at, published_at, duration, thumbnail_url
      FROM ordered
      WHERE
        cumulative_duration < 90 * 60;
    """

    results = ActiveRecord::Base.connection.execute(sql).to_a
    results.each_with_index.map { |r, idx| Recommendation.new(video: Video.find(r['id']), priority: priority, expires_at: r['expires_at'], thumbnail_url: r['thumbnail_url'], published_at: r['published_at'], duration: r['duration']) }
  end

  private
    def revoke_token
      user = Memair.new(self.memair_access_token)
      query = 'mutation {RevokeAccessToken{revoked}}'
      user.query(query)
    end

    def previous_watched_and_recommended(access_token)
      query = '''
        query{
          watched: DigitalActivities(first: 10000 type: watched_video order: desc order_by: timestamp){url}
          recommended: Recommendations(first: 10000 actioned: true order: desc order_by: timestamp){url}
        }'''
      response = Memair.new(access_token).query(query)
      {
        recommended: response['data']['recommended'].map{|r| youtube_id(r['url'])}.compact.uniq,
        watched: response['data']['watched'].map{|r| youtube_id(r['url'])}.compact.uniq
      }
    end
  
    def youtube_id(url)
      regex = /(?:youtube(?:-nocookie)?\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
      matches = regex.match(url)
      matches[1] unless matches.nil?
    end
end
