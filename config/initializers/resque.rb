require 'resque'
require 'resque/server'

rails_root = defined?(Rails) ? Rails.root : File.dirname(__FILE__) + '/../..'
rails_env = defined?(Rails) ? Rails.env : 'development'

redis_config = YAML.load_file(File.join(rails_root, "config", "redis.yml"))[rails_env] || {}
redis_config.symbolize_keys!

Resque.redis = Redis.new(redis_config)

module Resque
  class Server
    configure do
      enable :sessions
    end

    use Rack::Session::Cookie,
      :key => "_spot_session",
      :secret => Spot::Application.config.secret_token
    
    def warden
      request.env['warden']
    end
    
    def current_user(*args)
      warden.user(*args)
    end
    
    def authenticated?(*args)
      warden.authenticated?(*args)
    end
    
    before do
      redirect '/session/new' unless current_user && current_user.admin?
    end 
  end
end