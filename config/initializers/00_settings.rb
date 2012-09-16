unless defined?(Settings)
  require 'configuration'
  require Rails.root.join('config', 'settings', 'default')

  Configuration.path = [Rails.root.join('config', 'settings').to_s]

  if defined?(Rails) && Rails.respond_to?(:env)
    local_settings = Rails.root.join('config', 'settings', Rails.env.to_s).to_s
    require local_settings if File.exists?(local_settings + ".rb")
  end

  class CurrentConfiguration
    def initialize(env)
      @configuration = Configuration.for(env.to_s)
    end

    # "safe" accessor wrapper (returns nil instead of raising)
    def get(key)
      begin
        send(key)
      rescue
        nil
      end
    end

    # allows local env_var settings to be overidden by ENV['ENV_VAR']
    def method_missing(sym, *args, &block)
      key = sym.to_s
      if ENV[key.upcase]
        ENV[key.upcase]
      else
        @configuration.send(key, *args, &block)
      end
    end
  end

  if defined?(Rails) && Rails.respond_to?(:env)
    Settings = CurrentConfiguration.new(Rails.env)
  else
    Settings = CurrentConfiguration.new(:default)
  end
end
