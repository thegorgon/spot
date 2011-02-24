Factory.define :device do |d|
  d.udid {  ActiveSupport::SecureRandom.hex(16)  }
  d.user { |user| user.association(:user) }
  d.app_version "1.0"
  d.os_id       "iPhone 4.0"
  d.platform    "iPhone"
  d.token
end

Factory.define :user do |u|
end