Factory.define :wishlist_item do |wi|
  wi.association    :user
  wi.association    :item, :factory => :place
  wi.source_type    nil
  wi.source_id      nil
  wi.lat            { rand * 180 - 90 }
  wi.lng            { rand * 360 - 180 }
end

Factory.define :activity_item do |ai|
  ai.association  :actor, :factory => :user
  ai.association  :item, :factory => :place
  ai.association  :activity, :factory => :wishlist_item
  ai.source_type  nil
  ai.source_id    nil
  ai.action       "CREATE"
  ai.lat          { rand * 180 - 90 }
  ai.lng          { rand * 360 - 180 }
  ai.created_at   { Time.now }
end