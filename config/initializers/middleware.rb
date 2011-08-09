if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :except => /^\/blog/, :strict => true, :force_secure_cookies => false
end

Rails.configuration.middleware.use Rack::NoIE, :redirect => "/upgrade", :minimum => 8.0