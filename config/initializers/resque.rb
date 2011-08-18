require 'resque'
require 'resque/server'

rails_root = defined?(Rails) ? Rails.root : File.dirname(__FILE__) + '/../..'
rails_env = defined?(Rails) ? Rails.env : 'development'

redis_config = YAML.load_file(File.join(rails_root, "config", "redis.yml"))[rails_env] || {}
redis_config.symbolize_keys!

Resque.redis = Redis.new(redis_config)

Resque::Server.use AdminAuthentication

Resque.inline = rails_env == 'development' || rails_env == 'test'