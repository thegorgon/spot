Factory.define :google_place, :class => ExternalPlace::GooglePlace do |gp|
  gp.cid { Factory.next(:google_cid) }
  gp.name           'Place Name'
  gp.listing_type   'local business'
  gp.street_address '1 Test Lane'
  gp.city           'Testville'
  gp.region         'California'
  gp.country        'USA'
  gp.address        '1 Test Lane, Testville California USA'
  gp.phone_number   '555-555-5555'
  gp.lat { rand * 180 - 90 }
  gp.lng { rand * 360 - 180 }
  gp.association :place
end

Factory.define :yelp_place, :class => ExternalPlace::YelpPlace do |yp|
  yp.name             'Place Name'
  yp.phone            '555-555-5555'
  yp.address          '1 Test Lane'
  yp.city             'Testville'
  yp.state_code       'CA'
  yp.country_code     'USA'
  yp.postal_code      '94114'
  yp.cross_streets    '21st'
  yp.display_address  "1 Test Lane Testville, CA, USA"
  yp.neighborhoods    ["Mission"]
  yp.categories       ["Restaurant"]
  yp.geo_accuracy     6
  yp.lat              { rand * 180 - 90 }
  yp.lng              { rand * 360 - 180 }
  yp.yelp_id          'place-name'
  yp.association      :place
end

Factory.define :foursquare_place, :class => ExternalPlace::FoursquarePlace do |fp|
  fp.name             'Place Name'
  fp.categories       ["Restaurant"]
  fp.address          '1 Test Lane'
  fp.cross_street     '21st'
  fp.city             'Testville'
  fp.state            'CA'
  fp.postal_code      '94114'
  fp.country          'USA'
  fp.lat              { rand * 180 - 90 }
  fp.lng              { rand * 360 - 180 }
  fp.phone            '555-555-5555'
  fp.twitter          'place'
  fp.foursquare_id    'fa2e456dcab223'
  fp.association      :place
end

Factory.define :facebook_place, :class => ExternalPlace::FacebookPlace do |fp|
  fp.name             'Place Name'
  fp.category         "local business"
  fp.street           '1 Test Lane'
  fp.city             'Testville'
  fp.state            'CA'
  fp.country          'USA'
  fp.zip              '94114'
  fp.lat              { rand * 180 - 90 }
  fp.lng              { rand * 360 - 180 }
  fp.facebook_id     '10022938098098'
  fp.association      :place
end

Factory.define :gowalla_place, :class => ExternalPlace::GowallaPlace do |gp|
  gp.name             'Place Name'
  gp.street_address   '1 Test Lane'
  gp.region           'Testville'
  gp.locality         'CA'
  gp.iso3166          'USA'
  gp.radius_meters    50
  gp.lat              { rand * 180 - 90 }
  gp.lng              { rand * 360 - 180 }
  gp.phone_number     '555-555-5555'
  gp.categories       ["Restaurant"]
  gp.gowalla_id       10090
  gp.foursquare_id    'fa2e456dcab223'
  gp.association      :place
end

Factory.sequence :google_cid do |n|
  '%020i' % n
end

Factory.define :place do |p|
  p.full_name     'Place Name'
  p.full_address  "1 Test Lane\nTestville California USA"
  p.city          "Testville"  
  p.region        "California"
  p.country       "USA"
  p.phone_number  '555-555-5555'
  p.lat { rand * 180 - 90 }
  p.lng { rand * 360 - 180 }
end