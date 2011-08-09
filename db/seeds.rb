# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

sf = City.find_by_slug("sf")
sf ||= City.create({ "country_code" => "US", 
  "fqn" =>"san francisco, california, us", 
  "lat" => 37.7768, 
  "lng" => -122.4196, 
  "name" => "san francisco", 
  "population" => 808976, 
  "radius" => nil, 
  "region" => "california", 
  "region_code" => "ca", 
  "slug" => "sf", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0 
})

chitown = City.find_by_slug("chicago")
chitown ||= City.create({ "country_code" => "US", 
  "fqn" =>"chicago, illinois, us", 
  "lat" => 41.881944, 
  "lng" => -87.627778,
  "name" => "chicago", 
  "population" => 2896016, 
  "radius" => nil, 
  "region" => "illinois", 
  "region_code" => "il", 
  "slug" => "chicago", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0 
})

nyc = City.find_by_slug("nyc")
nyc ||= City.create({ "country_code" => "US", 
  "fqn" =>"new york, new york, us", 
  "lat" => 40.716667, 
  "lng" => -74, 
  "name" => "new york", 
  "population" => 8175133, 
  "radius" => nil, 
  "region" => "new york", 
  "region_code" => "ny", 
  "slug" => "nyc", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0 
})

la = City.find_by_slug("la")
la ||= City.create({ "country_code" => "US", 
  "fqn" =>"los angeles, california, us", 
  "lat" => 34.05,
  "lng" => -118.25, 
  "name" => "los angeles", 
  "population" => 3792621, 
  "radius" => nil, 
  "region" => "california", 
  "region_code" => "ca", 
  "slug" => "la", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0 
})

nola = City.find_by_slug("nola")
nola ||= City.create({ "country_code" => "US", 
  "fqn" =>"new orleans, louisiana, us", 
  "lat" => 29.966667,
  "lng" => -90.05,
  "name" => "new orleans", 
  "population" => 343829, 
  "radius" => nil, 
  "region" => "louisiana", 
  "region_code" => "la", 
  "slug" => "nola", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})
