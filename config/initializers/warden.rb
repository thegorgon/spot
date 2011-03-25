Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.failure_app = Site::SessionsController
  manager.default_scope = :user
  manager.scope_defaults(
    :user,
    :action     => :new,
    :strategies => [:facebook, :password, :perishable_token, :device, :cookie]
  )
end

Warden::Strategies.add(:cookie, Strategies::Cookie)
Warden::Strategies.add(:device, Strategies::Device)
Warden::Strategies.add(:facebook, Strategies::Facebook)
Warden::Strategies.add(:password, Strategies::Password)
Warden::Strategies.add(:perishable_token, Strategies::PerishableToken)

Warden::Manager.after_authentication do |user, warden, options|
  user.login!
end

Warden::Manager.after_set_user do |user, warden, options|
  domain = warden.request.session_options[:domain]
  warden.request.cookie_jar.signed[Strategies::Cookie.cookie_key] = Strategies::Cookie.cookie_value(user, :domain => domain)
end

Warden::Manager.before_logout do |user, warden, options|
  warden.request.cookie_jar.signed[Strategies::Cookie.cookie_key] = nil
end