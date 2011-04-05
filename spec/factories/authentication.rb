Factory.define :device do |d|
  d.udid {  ActiveSupport::SecureRandom.hex(16)  }
  d.association :user
  d.app_version "1.0"
  d.os_id       "iPhone 4.0"
  d.platform    "iPhone"
  d.token
end

Factory.define :password_account do |a|
  a.first_name     "Tester"
  a.last_name      "McGee"
  a.login         { Factory.next(:email) }
  a.password      "password"
  a.association   :user
end

Factory.define :facebook_account do |a|
  a.access_token  { Factory.next(:access_token) }
  a.first_name    "Facebook"
  a.last_name     "User"
  a.gender        "male"
  a.name          "Facebook User"
  a.email         { Factory.next(:email) }
  a.locale        "en_US"
  a.facebook_id   { Factory.next(:facebook_id) }
  a.association   :user
end

Factory.sequence :email do |n|
  "email#{n}@email#{n}.com"
end

Factory.sequence :access_token do |n|
  digest = Time.now.to_i.to_s
  20.times { |i| digest = Digest::SHA512.hexdigest(digest) }
  digest[0..20]
end

Factory.sequence :facebook_id do |n|
  10000000000 + n
end

Factory.define :user do |u|
  u.first_name    "Tester"
  u.last_name     "McGee"
  u.email         { Factory.next(:email) }
  u.locale        "en-US"
end