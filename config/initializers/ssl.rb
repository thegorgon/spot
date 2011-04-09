if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :except => /^\/places\/.+/
end