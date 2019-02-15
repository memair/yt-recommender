require "#{Rails.root}/app/helpers/memair_helper"
include MemairHelper

namespace :memair do
  desc "Make new recommendations"
  task :make_recommendations => :environment do
    puts "started at #{DateTime.now}"
    user = User.where('last_recommended_at IS NULL OR last_recommended_at < ?', 12.hours.ago).order('last_recommended_at ASC NULLS FIRST').first
    if user
      puts "recommending for #{user.email}"

      recommendations = user.get_recommendations
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