default = Configuration.for('default') do
  app_name 'knowflow'
  app_url 'knowflow.info'

  exception_sender 'errors@knowflow.info'
  admin_emails ['nap@zerosum.org']
  reply_email 'reply@knowflow.info'

  facebook_app_id 'facebook app id'
  facebook_app_secret 'facebook app secret'

  algolia_app_id 'algolia app id'
  algolia_api_key 'algolia read-write api key'
  algolia_search_key 'algolia read-only api key'
  algolia_index_name 'Question_production'

  ga_account ''
  ga_domain ''
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
