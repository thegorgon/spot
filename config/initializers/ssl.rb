if Rails.env.production?  
  Rails.configuration.middleware.use Rack::SslEnforcer, :except => [/^\/places\/.+/, /^\/previews\/\d+\/share\//], :strict => true
end