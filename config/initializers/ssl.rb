if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer
end