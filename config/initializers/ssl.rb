if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :hsts => { :expires => 500 }
end