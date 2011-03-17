Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :cookie, :device
  manager.failure_app = Site::BaseController
end

Warden::Strategies.add(:cookie, Strategies::Cookie)
Warden::Strategies.add(:device, Strategies::Device)

Warden::Manager.after_authentication do |user, warden, options|
  user.login!
end

Warden::Manager.after_set_user do |user, warden, options|
  domain = warden.request.session_options[:domain]
  warden.request.cookie_jar[Strategies::Cookie.cookie_key] = Strategies::Cookie.cookie_value(user, :domain => domain)
end

Warden::Manager.before_logout do |user, warden, options|
  warden.request.cookie_jar[Strategies::Cookie.cookie_key] = nil
end