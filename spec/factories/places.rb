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