include Devise::OmniAuth::UrlHelpers

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :memair, ENV['MEMAIR_CLIENT_ID'], ENV['MEMAIR_CLIENT_SECRET'], scope: 'biometric_read digital_activity_read emotion_read journal_read location_read physical_activity_read recommendation_write recommendation_read'
end
