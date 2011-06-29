# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

sf = City.create({ "country_code" => "US", 
  "fqn" =>"san francisco, california, US", 
  "lat" => 37.7768, 
  "lng" => -122.4196, 
  "name" => "san francisco", 
  "population" => 808976, 
  "radius" => nil, 
  "region" => "california", 
  "region_code" => "ca", 
  "slug" => "sf", 
  "subscription_count" => 0, 
  "subscriptions_available" => 10000 
})