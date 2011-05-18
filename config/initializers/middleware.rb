if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :hsts => { :expires => 500 }
end

Rails.configuration.middleware.use Rack::NoIE, :redirect => "/upgrade", :minimum => 8.0