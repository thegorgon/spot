# Be sure to restart your server when you modify this file.

redis_config = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))[Rails.env] || {}
uri = URI.parse(redis_config["servers"])
Redis.current = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :db => redis_config['db'])

session_config = {:expire_after => 30.days, :domain => :all, :key => "_spot_session"}
session_config.merge!(redis_config.symbolize_keys!)

Spot::Application.config.session_store :redis_session_store, session_config