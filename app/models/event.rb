class Event
  API_WISHLIST_LOAD         = 1
  API_WISHLIST_CREATE       = 2
  API_WISHLIST_DESTROY      = 3
  API_ACTIVITY_LOAD         = 4
  API_NONCE_FETCH           = 5
  API_LOGIN                 = 6
  API_LOGOUT                = 7
  API_PLACE_LOAD            = 8
  API_PLACE_SEARCH          = 9
  API_EXCEPTION             = 10
  
  uniq_constants!
  
  def self.lookup(string)
    const_get(string.gsub(/\s/, "_").upcase)
  end
end