module Jobs
  class WishlistTweeter
    @queue = :processing
    
    def self.perform(item_id)
      wishlist_item = WishlistItem.find(item_id)
      wishlist_item.create_tweets! if Rails.env.production?
    end
    
  end
end