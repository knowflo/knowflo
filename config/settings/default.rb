default = Configuration.for('default') do
  app_name 'knowflo'
  app_url 'knowflo.info'

  exception_sender 'errors@knowflo.info'
  admin_emails ['nap@zerosum.org']

  facebook_app_id 'facebook app id'
  facebook_app_secret 'facebook app secret'

  algolia_app_id 'algolia app id'
  algolia_api_key 'algolia read-write api key'
  algolia_search_key 'algolia read-only api key'
  algolia_index_name 'Question_production'
end

Configuration.for('development', default) do
  # customize development settings in config/settings/development.rb
end

Configuration.for('test', default) do
  # customize development settings in config/settings/test.rb
end

Configuration.for('production', default) do
  # customize development settings in config/settings/production.rb
end
