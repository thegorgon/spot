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

houston = City.find_by_slug("htown")
houston ||= City.create({ 
  "country_code" => "US", 
  "fqn" =>"houston, texas, us", 
  "lat" => 29.762778,
  "lng" => -95.383056,
  "name" => "houston", 
  "population" => 2099451, 
  "radius" => nil, 
  "region" => "texas", 
  "region_code" => "tx", 
  "slug" => "htown", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

philly = City.find_by_slug("philly")
philly ||= City.create({ 
  "country_code" => "US", 
  "fqn" =>"philadelphia, pennsylvania, us", 
  "lat" => 39.95,
  "lng" => -75.17,
  "name" => "philadelphia", 
  "population" => 5965343, 
  "radius" => nil, 
  "region" => "pennsylvania", 
  "region_code" => "pa", 
  "slug" => "philly", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

phoenix = City.find_by_slug("phoenix")
phoenix ||= City.create({ 
  "country_code" => "US", 
  "fqn" =>"phoenix, arizona, us", 
  "lat" => 33.4482,
  "lng" => -112.0738,
  "name" => "phoenix", 
  "population" => 4192887, 
  "radius" => nil, 
  "region" => "arizona", 
  "region_code" => "az", 
  "slug" => "phoenix", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

dallas = City.find_by_slug("dfw")
dallas ||= City.create({ 
  "country_code" => "US", 
  "fqn" =>"dallas, texas, us", 
  "lat" => 32.782778,
  "lng" => -96.803889,
  "name" => "dallas", 
  "population" => 1197816, 
  "radius" => nil, 
  "region" => "texas", 
  "region_code" => "tx", 
  "slug" => "dfw", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

seattle = City.find_by_slug("seattle") 
seattle ||= City.create({
  "country_code" => "US", 
  "fqn" =>"seattle, washington, us", 
  "lat" => 47.609722, 
  "lng" => -122.333056,
  "name" => "seattle", 
  "population" => 608660, 
  "radius" => nil, 
  "region" => "washington", 
  "region_code" => "wa", 
  "slug" => "seattle", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

portland = City.find_by_slug("ptown") 
portland ||= City.create({
  "country_code" => "US", 
  "fqn" =>"portland, oregon, us", 
  "lat" => 45.52,  
  "lng" => -122.681944,
  "name" => "portland", 
  "population" => 583776, 
  "radius" => nil, 
  "region" => "oregon", 
  "region_code" => "or", 
  "slug" => "ptown", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

denver = City.find_by_slug("denver")
denver ||= City.create({
  "country_code" => "US", 
  "fqn" =>"denver, colorado, us", 
  "lat" => 39.739167,   
  "lng" => -104.984722,
  "name" => "denver", 
  "population" => 1984887, 
  "radius" => nil, 
  "region" => "colorado", 
  "region_code" => "co", 
  "slug" => "denver", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0  
})

sandiego = City.find_by_slug("sd")
sandiego ||= City.create({
  "country_code" => "US", 
  "fqn" =>"san diego, california, us", 
  "lat" => 32.715,
  "lng" => -117.1625,
  "name" => "san diego", 
  "population" => 1301617, 
  "radius" => nil, 
  "region" => "california", 
  "region_code" => "ca", 
  "slug" => "sd", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})

boston = City.find_by_slug("boston")
boston ||= City.create({
  "country_code" => "US", 
  "fqn" =>"boston, massachusetts, us", 
  "lat" => 42.357778,
  "lng" => -71.061667,
  "name" => "boston", 
  "population" => 4032484, 
  "radius" => nil, 
  "region" => "massachusetts", 
  "region_code" => "ma", 
  "slug" => "boston", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})

miami = City.find_by_slug("miami")
miami ||= City.create({
  "country_code" => "US", 
  "fqn" =>"miami, florida, us", 
  "lat" => 25.787676,
  "lng" => -80.224145,
  "name" => "miami", 
  "population" => 5547051, 
  "radius" => nil, 
  "region" => "florida", 
  "region_code" => "fl", 
  "slug" => "miami", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})

dc = City.find_by_slug("dc")
dc ||= City.create({
  "country_code" => "US", 
  "fqn" =>"washington, district of columbia, us", 
  "lat" => 38.895111, 
  "lng" => -77.036667,
  "name" => "washington d.c.", 
  "population" => 5580000, 
  "radius" => nil, 
  "region" => "district of columbia", 
  "region_code" => "dc", 
  "slug" => "dc", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})

atlanta = City.find_by_slug("atlanta")
atlanta ||= City.create({
  "country_code" => "US", 
  "fqn" =>"atlanta, georgia, us", 
  "lat" => 33.755, 
  "lng" => -84.39,
  "name" => "atlanta", 
  "population" => 5268860, 
  "radius" => nil, 
  "region" => "georgia", 
  "region_code" => "ga", 
  "slug" => "atlanta", 
  "subscription_count" => 0, 
  "subscriptions_available" => 0
})