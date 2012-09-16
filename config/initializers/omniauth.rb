Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :facebook, Settings.facebook_app_id, Settings.facebook_app_secret,
           :scope => 'email, user_location, user_photos, user_about_me', :display => 'popup'
  # provider :twitter, Settings.twitter_consumer_key, Settings.twitter_consumer_secret
end
