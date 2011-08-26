if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, 
    :except => /^\/blog/, 
    :except_hosts => "api.spot-app.com",
    :strict => true, 
    :force_secure_cookies => false
end

require File.join(Rails.root, 'lib', 'middleware', 'noie.rb')

Rails.configuration.middleware.use Rack::NoIE, :redirect => "/upgrade", :minimum => 7.0