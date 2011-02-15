# Be sure to restart your server when you modify this file.

redis_config = YAML.load_file(File.join(Rails.root, "config", "redis.yml"))[Rails.env] || {}
session_config = {:expire_after => 30.days, :domain => :all, :key => "_spot_session"}.merge!(redis_config.symbolize_keys!)

puts session_config.inspect

Spot::Application.config.session_store :redis_session_store, session_config