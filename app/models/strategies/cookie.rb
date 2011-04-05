class Strategies::Cookie < Warden::Strategies::Base  
  DOMAIN_REGEXP = /[^.]*\.([^.]*|..\...|...\...)$/
  
  def self.cookie_key
    "user_credentials"
  end

  def self.cookie_value(user, options={})
    { :value => [user.persistence_token, user.id].join("::"),
      :path => "/",
      :expires => 3.months.from_now }.merge!(options)
  end

  def valid?
    Rails.logger.info("warden: testing validity of cookie strategy")
    request.cookie_jar.signed[self.class.cookie_key]
  end

  def authenticate!
    Rails.logger.info("warden: attempting authentication with cookie strategy")
    persistence_token, record_id = request.cookie_jar.signed[self.class.cookie_key].split("::")
    user = User.find_by_id(record_id)
    user && user.persistence_token == persistence_token ? success!(user) : fail!("Invalid cookie")
  end
end