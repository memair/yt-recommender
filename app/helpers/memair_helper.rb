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
end
