if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, { :expires => 500 }
end