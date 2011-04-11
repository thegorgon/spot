if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :only_hosts => /api\d*\.spot\-app\.com/
  Rails.configuration.middleware.use Rack::SslEnforcer, :except => [/^\/places\//, /^\/previews\/\d+\/share/], :strict => true, :except_hosts => /api\d*\.spot\-app\.com/
end