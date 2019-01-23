module MemairHelper

  def generate_recommendation_mutation(recommendations)
    raise TypeError, 'generate_recommendation_query expects an array of vidoes' unless recommendations.kind_of?(Array) && !recommendations.empty? && (recommendations.all? {|vid| vid.kind_of?(Recommendation)})
    recommendation_strings = recommendations.map { |recommendation|
      """
        {
          type: video
          source: \"YT Recommender\"
          priority: #{recommendation.priority}
          expires_at: \"#{recommendation.expires_at}\"
          url: \"https://youtu.be/#{recommendation.video.yt_id}\"
          title: \"#{recommendation.video.title.gsub('"', '\"').gsub('%', '%25')}\"
          description: \"#{recommendation.video.description.gsub('"', '\"').gsub('%', '%25')}\"
        }
      """
    }

    """
      mutation {
        BulkCreate(
          recommendations: [
            #{recommendation_strings.join}
          ]
        )
        {
          id
        }
      }
    """
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
