class Api::WishlistsController < Api::BaseController
  def activity
    @activity = WishlistItem.activity(params)
    render :json => @activity
  end
  
  def show
    @wishlist = current_user.wishlist_items.all(:include => :item)
    render :json => @wishlist
  end
end