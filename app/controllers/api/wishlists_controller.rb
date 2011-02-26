class Api::WishlistsController < Api::BaseController
  def activity
    @activity = WishlistItem.activity(params)
    render :json => @activity
  end
  
  def show
    Rails.logger.info("Current User ID : #{current_user.id}")
    @wishlist = current_user.wishlist_items.all(:include => :item)
    Rails.logger.info("Current User Wishlist : #{@wishlist.inspect}")
    render :json => @wishlist
  end
end